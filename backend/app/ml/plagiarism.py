from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

class PlagiarismDetector:
    @staticmethod
    def check_plagiarism(new_text, existing_texts):
        """
        Checks new_text against a list of existing_texts.
        Returns the maximum similarity score found (0.0 to 1.0).
        """
        if not new_text or not existing_texts:
            return 0.0

        clean_existing = [t for t in existing_texts if t and t.strip()]
        if not clean_existing:
            return 0.0

        # Add new text to corups
        corpus = [new_text] + clean_existing
        
        try:
            vectorizer = TfidfVectorizer()
            tfidf_matrix = vectorizer.fit_transform(corpus)
            
            # Compare first doc (new_text) against all others
            cosine_sim = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:])
            
            # Return max similarity
            return float(np.max(cosine_sim))
        except ValueError:
            return 0.0
