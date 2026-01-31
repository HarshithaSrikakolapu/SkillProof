from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.certificate import Certificate
from app import db
import os
from werkzeug.utils import secure_filename
from datetime import datetime

certificates_bp = Blueprint('certificates', __name__)

ALLOWED_EXTENSIONS = {'pdf', 'png', 'jpg', 'jpeg'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@certificates_bp.route('/', methods=['GET'])
@jwt_required()
def get_my_certificates():
    user_id = get_jwt_identity()
    certs = Certificate.query.filter_by(user_id=user_id).order_by(Certificate.uploaded_at.desc()).all()
    return jsonify([c.to_dict() for c in certs]), 200

@certificates_bp.route('/upload', methods=['POST'])
@jwt_required()
def upload_certificate():
    user_id = get_jwt_identity()
    
    if 'file' not in request.files:
        return jsonify({'message': 'No file part'}), 400
    
    file = request.files['file']
    name = request.form.get('name')
    issuer = request.form.get('issuer')
    issue_date_str = request.form.get('issue_date')

    if file.filename == '':
        return jsonify({'message': 'No selected file'}), 400
        
    if not all([name, issuer, issue_date_str]):
        return jsonify({'message': 'Missing metadata'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(f"{user_id}_{int(datetime.now().timestamp())}_{file.filename}")
        upload_dir = os.path.join(current_app.root_path, '..', 'uploads', 'certificates')
        os.makedirs(upload_dir, exist_ok=True)
        
        file_path = os.path.join(upload_dir, filename)
        file.save(file_path)

        try:
            issue_date = datetime.strptime(issue_date_str, '%Y-%m-%d').date()
        except ValueError:
             return jsonify({'message': 'Invalid date format. Use YYYY-MM-DD'}), 400

        cert = Certificate(
            user_id=user_id,
            name=name,
            issuer=issuer,
            issue_date=issue_date,
            file_path=file_path
        )
        
        db.session.add(cert)
        db.session.commit()
        
        return jsonify(cert.to_dict()), 201

    return jsonify({'message': 'Invalid file type'}), 400

@certificates_bp.route('/<int:cert_id>', methods=['DELETE'])
@jwt_required()
def delete_certificate(cert_id):
    user_id = get_jwt_identity()
    cert = Certificate.query.filter_by(id=cert_id, user_id=user_id).first()
    
    if not cert:
        return jsonify({'message': 'Certificate not found'}), 404
        
    db.session.delete(cert)
    db.session.commit()
    
    # Optionally delete file from disk, but skipping for safety in this demo
    
    return jsonify({'message': 'Deleted successfully'}), 200
