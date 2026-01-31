from flask import Blueprint, request, jsonify
from app.services.auth_service import AuthService
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    role = data.get('role', 'Learner')

    if not email or not password:
        return jsonify({'message': 'Email and password are required'}), 400

    user, error = AuthService.register_user(email, password, role, full_name)
    if error:
        return jsonify({'message': error}), 400

    return jsonify({'message': 'User registered successfully', 'user': user.to_dict()}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    result, error = AuthService.login_user(email, password)
    if error:
        return jsonify({'message': error}), 401

    return jsonify(result), 200

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def me():
    current_user_id = get_jwt_identity()
    claims = get_jwt()
    # In a real app, you might want to fetch fresh user data from DB
    return jsonify({
        'id': current_user_id,
        'role': claims.get('role')
    }), 200
