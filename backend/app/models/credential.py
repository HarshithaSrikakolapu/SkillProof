from app import db
from datetime import datetime
import uuid

class Credential(db.Model):
    __tablename__ = 'credentials'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    skill_id = db.Column(db.Integer, db.ForeignKey('skills.id'), nullable=False)
    level = db.Column(db.String(20), nullable=False) # Beginner, Intermediate, Advanced
    score_achieved = db.Column(db.Float, nullable=False)
    signature = db.Column(db.String(64), nullable=True) # HMAC-SHA256
    issued_at = db.Column(db.DateTime, default=datetime.utcnow)

    skill = db.relationship('Skill')
    user = db.relationship('User')

    def to_dict(self):
        return {
            'id': self.id,
            'user_name': self.user.email, # Should ideally be full name
            'skill_name': self.skill.name,
            'level': self.level,
            'score': self.score_achieved,
            'signature': self.signature,
            'issued_at': self.issued_at.isoformat()
        }
