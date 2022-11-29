FROM python:3.9

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y \
  gcc \
  g++ \
  git \
  make \
  python3-dev \
  python3-venv \
  unzip \
  wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://github.com/duckdb/duckdb/releases/download/v0.5.1/duckdb_cli-linux-amd64.zip && unzip duckdb_cli-linux-amd64.zip \
  && pip install --no-cache-dir meltano==2.10.0

COPY meltano.yml /usr/src/app/

RUN meltano --log-level=debug --environment=docker install extractors
RUN meltano --log-level=debug --environment=docker install loaders
RUN meltano --log-level=debug --environment=docker install mappers
RUN meltano --log-level=debug --environment=docker install utility dbt-duckdb
RUN meltano --log-level=debug --environment=docker install utility superset

COPY data ./data
COPY transform ./transform
COPY visuals ./visuals
COPY Makefile .
