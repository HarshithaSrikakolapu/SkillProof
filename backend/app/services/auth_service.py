from app.models.user import User
from app import db
from flask_jwt_extended import create_access_token

class AuthService:
    @staticmethod
    def register_user(email, password, role, full_name=None):
        if User.query.filter_by(email=email).first():
            return None, "User already exists"
        
        # specific logic to allow/disallow generic Role selection
        allowed_roles = ['Learner', 'Employer', 'Assessor', 'Admin']
        if role not in allowed_roles:
            return None, "Invalid role"

        new_user = User(email=email, role=role, full_name=full_name)
        new_user.set_password(password)
        
        db.session.add(new_user)
        db.session.commit()
        
        return new_user, None

    @staticmethod
    def login_user(email, password):
        user = User.query.filter_by(email=email).first()
        if user and user.check_password(password):
            access_token = create_access_token(identity=str(user.id), additional_claims={'role': user.role})
            return {
                'access_token': access_token,
                'user': user.to_dict()
            }, None
        return None, "Invalid credentials"
