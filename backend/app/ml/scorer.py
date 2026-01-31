from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

class Scorer:
    @staticmethod
    def calculate_similarity(text1, text2):
        if not text1 or not text2:
            return 0.0
        
        try:
            vectorizer = TfidfVectorizer()
            tfidf_matrix = vectorizer.fit_transform([text1, text2])
            similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])
            return float(similarity[0][0])
        except ValueError:
            # Happens if content is empty or stop words only
            return 0.0

    @staticmethod
    def score_text_answer(student_answer, reference_answer):
        """
        Scores a student answer against a reference answer (0.0 to 1.0)
        """
        return Scorer.calculate_similarity(student_answer, reference_answer)
