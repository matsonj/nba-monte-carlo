FROM nikolaik/python-nodejs:python3.11-nodejs20-bullseye

ARG SSL_KEYSTORE_PASSWORD
USER root

WORKDIR /workspaces/nba-monte-carlo

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
  gfortran \
  musl-dev \
  glibc-source \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-amd64.zip && unzip duckdb_cli-linux-amd64.zip \
  && curl -LsSf https://astral.sh/uv/install.sh | sh

COPY data ./data
COPY dlt ./dlt
COPY transform ./transform
COPY Makefile .
COPY evidence ./evidence
# add dependencies for uv
COPY .python-version .
COPY pyproject.toml .
COPY uv.lock .

RUN make build
