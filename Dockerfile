FROM python:3.13-slim

WORKDIR /app

COPY app/app.py .
COPY app/requirements.txt .

RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y curl

ENV STORAGE="redis"
ENV REDIS_URL="redis://redis:6379/0"

USER 10001:10001

EXPOSE 8080

CMD ["python", "app.py"]