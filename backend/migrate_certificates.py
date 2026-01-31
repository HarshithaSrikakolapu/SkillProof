import sqlite3
import os

DB_FILE = os.path.join('instance', 'skill_validation.db')

def migrate():
    if not os.path.exists(DB_FILE):
        print(f"DB {DB_FILE} not found!")
        return

    print(f"Migrating {DB_FILE}...")
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS certificates (
            id INTEGER PRIMARY KEY,
            user_id INTEGER NOT NULL,
            name VARCHAR(200) NOT NULL,
            issuer VARCHAR(200) NOT NULL,
            issue_date DATE NOT NULL,
            file_path VARCHAR(500) NOT NULL,
            uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )
        ''')
        
        print("✅ Table 'certificates' created/verified.")
        conn.commit()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    migrate()
