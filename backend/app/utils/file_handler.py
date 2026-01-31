import os
from werkzeug.utils import secure_filename
import uuid

# Hack to locate uploads in root
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif', 'py', 'dart', 'js', 'zip', 'mp4'}

if not os.path.exists(UPLOAD_FOLDER):
    try:
        os.makedirs(UPLOAD_FOLDER)
    except OSError:
        pass

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def save_file(file, subdir='common'):
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        
        target_dir = os.path.join(UPLOAD_FOLDER, subdir)
        if not os.path.exists(target_dir):
            try:
                os.makedirs(target_dir)
            except OSError:
                pass
            
        file_path = os.path.join(target_dir, unique_filename)
        file.save(file_path)
        
        # Return relative path for DB
        return os.path.join('uploads', subdir, unique_filename).replace('\\', '/')
    return None
