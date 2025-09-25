FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Provide C headers and libraries for building psycopg2
        libpq-dev \
        # Provide the C compiler (gcc)
        build-essential && \
    \
    pip install --no-cache-dir -r requirements.txt && \
    \
    # Clean up build dependencies to keep the image small
    apt-get purge -y --auto-remove build-essential && \
    rm -rf /var/lib/apt/lists/*

COPY . .

ARG POSTGRES_HOST
ARG POSTGRES_PORT
ARG POSTGRES_NAME
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

ENV POSTGRES_HOST=${POSTGRES_HOST}
ENV POSTGRES_PORT=${POSTGRES_PORT}
ENV POSTGRES_NAME=${POSTGRES_NAME}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]