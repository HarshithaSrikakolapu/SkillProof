from app import db
from datetime import datetime

class Certificate(db.Model):
    __tablename__ = 'certificates'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name = db.Column(db.String(200), nullable=False)
    issuer = db.Column(db.String(200), nullable=False)
    issue_date = db.Column(db.Date, nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'issuer': self.issuer,
            'issue_date': self.issue_date.isoformat(),
            'file_url': f"/files/uploads/certificates/{self.file_path.split('/')[-1]}", # simplified URL
            'uploaded_at': self.uploaded_at.isoformat()
        }
