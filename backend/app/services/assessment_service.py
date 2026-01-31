from app.models.assessment import Skill, Assessment, UserAssessment
from app import db
from datetime import datetime

class AssessmentService:
    @staticmethod
    def get_all_skills():
        return Skill.query.all()

    @staticmethod
    def create_skill(name, description):
        skill = Skill(name=name, description=description)
        db.session.add(skill)
        db.session.commit()
        return skill

    @staticmethod
    def get_assessments_by_skill(skill_id):
        return Assessment.query.filter_by(skill_id=skill_id).all()

    @staticmethod
    def create_assessment(skill_id, title, description, difficulty, time_limit, content):
        assessment = Assessment(
            skill_id=skill_id,
            title=title,
            description=description,
            difficulty_level=difficulty,
            time_limit_minutes=time_limit,
            content=content
        )
        db.session.add(assessment)
        db.session.commit()
        return assessment

    @staticmethod
    def start_assessment(user_id, assessment_id):
        # Check if already started/completed? 
        # For mvp simplify: create new entry
        ua = UserAssessment(user_id=user_id, assessment_id=assessment_id)
        db.session.add(ua)
        db.session.commit()
        return ua

    @staticmethod
    def submit_assessment(ua_id, responses):
        from app.ml.scorer import Scorer
        from app.ml.plagiarism import PlagiarismDetector

        ua = UserAssessment.query.get(ua_id)
        if not ua:
            return None, "Assessment attempt not found"
        
        ua.responses = responses
        ua.submitted_at = datetime.utcnow()
        ua.status = 'Submitted'
        
        # --- ML Evaluation ---
        # 1. Get Reference Data
        assessment = ua.assessment
        content = assessment.content or {}
        # Assuming content['questions'] list, and responses is dict 'q1': 'ans' (or similar mapping)
        # For MVP, let's assume single text answer in 'text_answer' key
        
        student_text = responses.get('text_answer', '')
        
        # Calculate Score (vs Reference)
        # We need a reference answer. Let's look for it in content, or default to generic matching
        reference_text = content.get('reference_answer', 'This is a sample reference answer explaining the concept.')
        
        score = Scorer.score_text_answer(student_text, reference_text)
        ua.score = round(score * 100, 2) # 0-100 scale

        # 2. Check Plagiarism (vs Other Students)
        # Get all other submissions for this assessment
        others = UserAssessment.query.filter(
            UserAssessment.assessment_id == ua.assessment_id,
            UserAssessment.id != ua.id,
            UserAssessment.responses.isnot(None)
        ).all()
        
        other_texts = []
        for o in others:
            if o.responses:
                 # Extract text_answer from JSON
                 if isinstance(o.responses, dict):
                     other_texts.append(o.responses.get('text_answer', ''))
        
        plagiarism_score = PlagiarismDetector.check_plagiarism(student_text, other_texts)
        # Store plagiarism score in responses metadata or separate field if exists
        # For now, let's just log it or append to score note?
        # Let's add it to responses for visibility
        responses['plagiarism_score'] = round(plagiarism_score * 100, 2)
        ua.responses = responses # Update dict

        # 3. Issue Credential if Passed
        PASSING_SCORE = 60.0
        if ua.score >= PASSING_SCORE:
            from app.models.credential import Credential
            # Check if already has credential for this skill?
            existing_cred = Credential.query.filter_by(user_id=ua.user_id, skill_id=ua.assessment.skill_id).first()
            if not existing_cred:
                cred = Credential(
                    user_id=ua.user_id,
                    skill_id=ua.assessment.skill_id,
                    level=ua.assessment.difficulty_level,
                    score_achieved=ua.score
                )
                db.session.add(cred)
                db.session.flush() # Get ID
                
                # Generate Signature
                from app.utils.security import SecurityUtils
                data_to_sign = f"{cred.id}{cred.user_id}{cred.score_achieved}"
                cred.signature = SecurityUtils.generate_signature(data_to_sign)
                db.session.add(cred)

        db.session.commit()
        return ua, None
