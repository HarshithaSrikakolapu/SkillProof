import sqlite3
import os

# Target the instance DB this time
DB_FILE = os.path.join('instance', 'skill_validation.db')

def verify_and_fix():
    if not os.path.exists(DB_FILE):
        print(f"Active DB {DB_FILE} not found. Maybe it's in root?")
        return

    print(f"Checking {DB_FILE}...")
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        
        # Check users.full_name
        try:
            cursor.execute("SELECT full_name FROM users LIMIT 1")
            print("✅ users.full_name exists.")
        except sqlite3.OperationalError:
            print("❌ users.full_name MISSING. Adding it...")
            cursor.execute("ALTER TABLE users ADD COLUMN full_name VARCHAR(100)")
            conn.commit()
            print("✅ users.full_name ADDED.")

        # Check credentials.signature
        try:
            cursor.execute("SELECT signature FROM credentials LIMIT 1")
            print("✅ credentials.signature exists.")
        except sqlite3.OperationalError:
            print("❌ credentials.signature MISSING. Adding it...")
            cursor.execute("ALTER TABLE credentials ADD COLUMN signature VARCHAR(64)")
            conn.commit()
            print("✅ credentials.signature ADDED.")
            
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    verify_and_fix()
