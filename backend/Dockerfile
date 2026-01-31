# Use official Python runtime as a parent image
FROM python:3.9-slim

# Set work directory
WORKDIR /app

# Install system dependencies (e.g. for psycopg2)
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Expose port
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=run.py

# Run commands
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "run:app"]
