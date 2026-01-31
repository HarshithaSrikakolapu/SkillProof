from app import db
from datetime import datetime

class Skill(db.Model):
    __tablename__ = 'skills'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    assessments = db.relationship('Assessment', backref='skill', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description
        }

class Assessment(db.Model):
    __tablename__ = 'assessments'

    id = db.Column(db.Integer, primary_key=True)
    skill_id = db.Column(db.Integer, db.ForeignKey('skills.id'), nullable=False)
    title = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text, nullable=False)
    difficulty_level = db.Column(db.String(20), nullable=False) # Beginner, Intermediate, Advanced
    time_limit_minutes = db.Column(db.Integer, nullable=False) # 0 for no limit
    content = db.Column(db.JSON, nullable=False) # Questions, Tasks, etc.
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'skill_id': self.skill_id,
            'title': self.title,
            'description': self.description,
            'difficulty_level': self.difficulty_level,
            'time_limit_minutes': self.time_limit_minutes,
            'content': self.content
        }

class UserAssessment(db.Model):
    __tablename__ = 'user_assessments'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    assessment_id = db.Column(db.Integer, db.ForeignKey('assessments.id'), nullable=False)
    status = db.Column(db.String(20), default='Started') # Started, Submitted, Graded
    score = db.Column(db.Float, nullable=True)
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    submitted_at = db.Column(db.DateTime, nullable=True)
    responses = db.Column(db.JSON, nullable=True)
    
    assessment = db.relationship('Assessment')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'assessment_id': self.assessment_id,
            'status': self.status,
            'score': self.score,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'submitted_at': self.submitted_at.isoformat() if self.submitted_at else None
        }
