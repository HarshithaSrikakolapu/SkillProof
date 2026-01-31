from app import create_app, db
from app.models.assessment import Skill, Assessment

app = create_app()

def seed_data():
    with app.app_context():
        # Clear existing
        # db.drop_all() 
        # db.create_all()

        if not Skill.query.filter_by(name='Python').first():
            py_skill = Skill(name='Python', description='General Python programming skills')
            flutter_skill = Skill(name='Flutter', description='Flutter mobile development')
            db.session.add_all([py_skill, flutter_skill])
            db.session.commit()
            
            print("Skills seeded.")

            # Assessments
            a1 = Assessment(
                skill_id=py_skill.id,
                title='Python Basics',
                description='Test your knowledge of lists, dicts, and loops.',
                difficulty_level='Beginner',
                time_limit_minutes=30,
                content={
                    'questions': [{'q': 'What is a list?', 'type': 'text'}],
                    'reference_answer': 'A list is a mutable, ordered sequence of elements enclosed in square brackets.'
                }
            )
            
            a2 = Assessment(
                skill_id=flutter_skill.id,
                title='Widget Trees',
                description='Understand Stateless vs Stateful widgets.',
                difficulty_level='Intermediate',
                time_limit_minutes=45,
                content={'questions': [{'q': 'Explain setState', 'type': 'text'}]}
            )
            
            db.session.add_all([a1, a2])
            db.session.commit()
            print("Assessments seeded.")
        else:
            print("Already seeded.")

if __name__ == '__main__':
    seed_data()
