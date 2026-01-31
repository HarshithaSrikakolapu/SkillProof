from flask import Blueprint, jsonify
from app import db
from app.models.assessment import UserAssessment, Assessment, Skill
from app.models.credential import Credential
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import func

analytics_bp = Blueprint('analytics', __name__)

@analytics_bp.route('/user/me', methods=['GET'])
@jwt_required()
def get_user_progress():
    user_id = get_jwt_identity()
    
    # 1. Scores over time (for Line Chart)
    # Join Assessment to get Skill Name if needed
    attempts = db.session.query(
        UserAssessment.submitted_at,
        UserAssessment.score,
        Assessment.title
    ).join(Assessment).filter(
        UserAssessment.user_id == user_id,
        UserAssessment.score.isnot(None)
    ).order_by(UserAssessment.submitted_at).all()
    
    # 2. Credentials Earned
    creds_count = Credential.query.filter_by(user_id=user_id).count()

    return jsonify({
        'progress': [{
            'date': a.submitted_at.isoformat(),
            'score': a.score,
            'title': a.title
        } for a in attempts],
        'credentials_count': creds_count
    }), 200

@analytics_bp.route('/skills', methods=['GET'])
def get_global_skill_stats():
    # Public or Auth required? Let's keep public for "Market Trends"
    # Avg score per Skill
    stats = db.session.query(
        Skill.name,
        func.avg(UserAssessment.score),
        func.count(UserAssessment.id)
    ).select_from(UserAssessment).join(Assessment).join(Skill).filter(
        UserAssessment.score.isnot(None)
    ).group_by(Skill.name).all()
    
    return jsonify([{
        'skill': s[0],
        'avg_score': round(s[1], 2) if s[1] else 0,
        'attempts': s[2]
    } for s in stats]), 200
