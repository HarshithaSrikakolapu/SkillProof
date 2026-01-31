from flask import Blueprint, jsonify, request
from app.models.user import User
from app.models.assessment import UserAssessment
from app.models.credential import Credential
from flask_jwt_extended import jwt_required

employer_bp = Blueprint('employer', __name__)

@employer_bp.route('/candidates', methods=['GET'])
@jwt_required()
def search_candidates():
    # In real app, check if current_user.role == 'Employer'
    query = request.args.get('q', '')
    
    if query:
        candidates = User.query.filter(User.role == 'Learner', User.email.ilike(f'%{query}%')).all()
    else:
        candidates = User.query.filter_by(role='Learner').all()
        
    return jsonify([{
        'id': u.id,
        'email': u.email,
        'created_at': u.created_at.isoformat()
    } for u in candidates]), 200

@employer_bp.route('/candidates/<int:user_id>', methods=['GET'])
@jwt_required()
def get_candidate_profile(user_id):
    user = User.query.get(user_id)
    if not user or user.role != 'Learner':
        return jsonify({'message': 'Candidate not found'}), 404

    # Fetch Credentials
    creds = Credential.query.filter_by(user_id=user_id).all()
    
    # Fetch Assessments (Evidence)
    assessments = UserAssessment.query.filter_by(user_id=user_id).all()

    return jsonify({
        'user': user.to_dict(),
        'credentials': [c.to_dict() for c in creds],
        'assessments': [ua.to_dict() for ua in assessments]
    }), 200
