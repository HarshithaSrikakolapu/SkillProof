import hashlib
import hmac
import os
from flask import current_app

class SecurityUtils:
    @staticmethod
    def generate_signature(data_string):
        """
        Generates HMAC-SHA256 signature for data_string using SECRET_KEY
        """
        secret = current_app.config['SECRET_KEY'].encode('utf-8')
        return hmac.new(secret, data_string.encode('utf-8'), hashlib.sha256).hexdigest()

    @staticmethod
    def verify_signature(data_string, signature):
        """
        Verifies the signature matches the data
        """
        expected = SecurityUtils.generate_signature(data_string)
        return hmac.compare_digest(expected, signature)

    @staticmethod
    def calculate_file_hash(file_path):
        """
        Calculates SHA256 hash of a file
        """
        sha256_hash = hashlib.sha256()
        try:
            with open(file_path, "rb") as f:
                for byte_block in iter(lambda: f.read(4096), b""):
                    sha256_hash.update(byte_block)
            return sha256_hash.hexdigest()
        except FileNotFoundError:
            return None
