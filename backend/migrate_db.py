import sqlite3
import os

DB_FILE = 'skill_validation.db'

def run_migration():
    if not os.path.exists(DB_FILE):
        print(f"Database {DB_FILE} not found!")
        return

    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        
        # 1. Check and Add 'full_name' to 'users'
        try:
            cursor.execute("SELECT full_name FROM users LIMIT 1")
            print("'users.full_name' already exists.")
        except sqlite3.OperationalError:
            print("Adding 'full_name' to 'users' table...")
            cursor.execute("ALTER TABLE users ADD COLUMN full_name VARCHAR(100)")
            print("Done.")

        # 2. Check and Add 'signature' to 'credentials'
        try:
            cursor.execute("SELECT signature FROM credentials LIMIT 1")
            print("'credentials.signature' already exists.")
        except sqlite3.OperationalError:
            print("Adding 'signature' to 'credentials' table...")
            cursor.execute("ALTER TABLE credentials ADD COLUMN signature VARCHAR(64)")
            print("Done.")

        conn.commit()
        conn.close()
        print("Migration completed successfully.")
    except Exception as e:
        print(f"Migration Failed: {e}")

if __name__ == '__main__':
    run_migration()
