from flask import Blueprint, jsonify
from app.models.credential import Credential
from flask_jwt_extended import jwt_required, get_jwt_identity

credentials_bp = Blueprint('credentials', __name__)

@credentials_bp.route('/me', methods=['GET'])
@jwt_required()
def get_my_credentials():
    user_id = get_jwt_identity()
    creds = Credential.query.filter_by(user_id=user_id).all()
    return jsonify([c.to_dict() for c in creds]), 200

@credentials_bp.route('/<string:cred_id>', methods=['GET'])
def verify_credential(cred_id):
    # Public verification endpoint (no auth needed)
    cred = Credential.query.get(cred_id)
    if not cred:
        return jsonify({'message': 'Credential not found'}), 404
        
    # Verify Integrity
    from app.utils.security import SecurityUtils
    data_to_sign = f"{cred.id}{cred.user_id}{cred.score_achieved}"
    if not cred.signature or not SecurityUtils.verify_signature(data_to_sign, cred.signature):
         return jsonify({'message': 'Credential verification failed: Invalid Signature'}), 400
         
    return jsonify(cred.to_dict()), 200
