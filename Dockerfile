# Stage 1: Build Stage
ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION} as builder

WORKDIR /app
COPY . .

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app
ENV PYTHONUNBUFFERED=1

COPY --from=builder /app .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    apt-get update && apt-get install -y --no-install-recommends netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080

# Wait for DB, then migrate, then run server
ENTRYPOINT ["sh", "-c", "until nc -z db 3306; do echo 'Waiting for db...'; sleep 1; done; python manage.py migrate && python manage.py runserver 0.0.0.0:8080"]
