from app import create_app, db
from app.models.assessment import Assessment

app = create_app()

def update_seed():
    with app.app_context():
        a1 = Assessment.query.get(1)
        if a1:
            a1.content = {
                'questions': [{'q': 'What is a list?', 'type': 'text'}],
                'reference_answer': 'A list is a mutable, ordered sequence of elements enclosed in square brackets.'
            }
            db.session.commit()
            print("Assessment 1 updated.")
        else:
            print("Assessment 1 not found.")

if __name__ == '__main__':
    update_seed()
