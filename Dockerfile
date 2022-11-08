FROM meltano/meltano

RUN apt-get update && apt-get install -y \
  unzip \
  wget

RUN wget https://github.com/duckdb/duckdb/releases/download/v0.5.1/duckdb_cli-linux-amd64.zip && unzip duckdb_cli-linux-amd64.zip

WORKDIR /usr/src/app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN make build
RUN make pipeline

ENTRYPOINT ["/bin/bash"]
