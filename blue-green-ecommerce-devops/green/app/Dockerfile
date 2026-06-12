# Green App Dockerfile
FROM python:3.11-slim

LABEL maintainer="devops-demo"
LABEL version="2.0"
LABEL description="Green E-Commerce Store – Version 2"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

ENV FLASK_ENV=production

CMD ["python", "app.py"]
