# Blue App Dockerfile
FROM python:3.11-slim

LABEL maintainer="devops-demo"
LABEL version="1.0"
LABEL description="Blue E-Commerce Store – Version 1"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

ENV FLASK_ENV=production

CMD ["python", "app.py"]
