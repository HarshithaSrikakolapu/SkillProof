from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_migrate import Migrate
from config import Config

from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_cors import CORS

db = SQLAlchemy()
jwt = JWTManager()
migrate = Migrate()
limiter = Limiter(key_func=get_remote_address, default_limits=["200 per day", "50 per hour"])

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Enable CORS with explicit permissions
    CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

    db.init_app(app)
    jwt.init_app(app)
    migrate.init_app(app, db)
    limiter.init_app(app)

    from app.api.auth import auth_bp
    app.register_blueprint(auth_bp, url_prefix='/auth')

    from app.api.skills import skills_bp
    app.register_blueprint(skills_bp, url_prefix='/skills')
    
    from app.api.credentials import credentials_bp
    app.register_blueprint(credentials_bp, url_prefix='/credentials')

    from app.api.employer import employer_bp
    app.register_blueprint(employer_bp, url_prefix='/employer')
    
    from app.api.analytics import analytics_bp
    app.register_blueprint(analytics_bp, url_prefix='/analytics')

    from app.api.common import common_bp
    app.register_blueprint(common_bp, url_prefix='/files')

    from app.api.certificates import certificates_bp
    app.register_blueprint(certificates_bp, url_prefix='/certificates')

    @app.route('/')
    def index():
        return "Skill Validation Platform API is running. Access endpoints at /auth, /skills, etc."

    return app
