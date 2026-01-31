from flask import Blueprint, request, jsonify
from app.services.assessment_service import AssessmentService
from flask_jwt_extended import jwt_required, get_jwt_identity

skills_bp = Blueprint('skills', __name__)

@skills_bp.route('/', methods=['GET'])
@jwt_required()
def get_skills():
    skills = AssessmentService.get_all_skills()
    return jsonify([s.to_dict() for s in skills]), 200

@skills_bp.route('/', methods=['POST'])
@jwt_required()
def create_skill():
    # Admin only check (omitted for MVP speed)
    data = request.get_json()
    skill = AssessmentService.create_skill(data['name'], data.get('description'))
    return jsonify(skill.to_dict()), 201

@skills_bp.route('/<int:skill_id>/assessments', methods=['GET'])
@jwt_required()
def get_assessments(skill_id):
    assessments = AssessmentService.get_assessments_by_skill(skill_id)
    return jsonify([a.to_dict() for a in assessments]), 200

@skills_bp.route('/assessments', methods=['POST'])
@jwt_required()
def create_assessment():
    # Admin only check
    data = request.get_json()
    assessment = AssessmentService.create_assessment(
        skill_id=data['skill_id'],
        title=data['title'],
        description=data['description'],
        difficulty=data['difficulty_level'],
        time_limit=data['time_limit_minutes'],
        content=data['content']
    )
    return jsonify(assessment.to_dict()), 201

@skills_bp.route('/assessments/<int:assessment_id>/start', methods=['POST'])
@jwt_required()
def start_assessment(assessment_id):
    user_id = get_jwt_identity()
    ua = AssessmentService.start_assessment(user_id, assessment_id)
    return jsonify(ua.to_dict()), 201

@skills_bp.route('/assessments/submit', methods=['POST'])
@jwt_required()
def submit_assessment():
    from app.utils.file_handler import save_file
    import json

    # Handle FormData: 'data' field has JSON, files are separate
    form_data = request.form.get('data')
    if not form_data:
        # Fallback if user sends raw json? No, Flutter sends FormData. 
        # But for robust testing if data is in json, handle it?
        # For now strict FormData
        return jsonify({'message': 'No data provided'}), 400
    
    try:
        data = json.loads(form_data)
    except json.JSONDecodeError:
         return jsonify({'message': 'Invalid JSON in data field'}), 400

    ua_id = data.get('user_assessment_id')
    user_responses = data.get('responses', {}) # Dictionary of Key -> Value

    # Process Files
    # Expecting keys like "q1_file", "evidence_video", etc. in request.files
    created_files = []
    
    for key, file in request.files.items():
        if file:
            saved_path = save_file(file, subdir=str(ua_id))
            if saved_path:
                user_responses[key] = saved_path
                created_files.append(saved_path)

    # Now call service with updated responses (paths included)
    ua, error = AssessmentService.submit_assessment(ua_id, user_responses)
    if error:
        return jsonify({'message': error}), 400
        
    return jsonify(ua.to_dict()), 200
