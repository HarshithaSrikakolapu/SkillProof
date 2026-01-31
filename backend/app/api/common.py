from flask import Blueprint, send_file, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
import os

common_bp = Blueprint('common', __name__)

@common_bp.route('/uploads/<path:filename>', methods=['GET'])
@jwt_required()
def get_file(filename):
    # Secure file access: Ensure user has right to view this file?
    # For MVP, allow any authenticated user to view files (e.g. proof)
    # In production, check UserAssessment ownership or Employer Role.
    
    uploads_dir = os.path.join(current_app.root_path, '../uploads') # Hacky
    # Or better use configured UPLOAD_FOLDER
    
    # We normalized paths in DB to 'uploads/common/...'
    # If filename passed is 'common/xyz', full path is root/uploads/common/xyz
    
    # Check traversal
    if '..' in filename or filename.startswith('/'):
        return jsonify({'message': 'Invalid filename'}), 400
        
    # Construct absolute path in a way that respects the 'uploads' folder relative to backend
    # Our save_file saved to d:/HackForge2/backend/uploads
    # This blueprint is in d:/HackForge2/backend/app/api
    
    # Let's rely on os.getcwd() which is d:/HackForge2/backend
    abs_path = os.path.join(os.getcwd(), 'uploads', filename)
    
    if os.path.exists(abs_path):
        return send_file(abs_path)
    else:
        return jsonify({'message': 'File not found'}), 404
