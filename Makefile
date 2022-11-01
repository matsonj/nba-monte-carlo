pip_install:
	pip install pipx
	pipx install meltano
	pipx install localstack

build: pip_install
	meltano install

start_s3:
	localstack start -d

init_s3:
	awslocal s3 mb s3://datalake

run:
	meltano run tap-spreadsheets-anywhere target-duckdb --full-refresh dbt-duckdb:build

parquet:
	meltano run tap-spreadsheets-anywhere target-parquet --full-refresh;\
	awslocal s3 sync /tmp/data_catalog/psa s3://datalake/psa;\
	meltano invoke dbt-duckdb run-operation elo_rollforward --target parquet;\
	meltano invoke dbt-duckdb build --target parquet

pipeline:
	meltano run tap-spreadsheets-anywhere target-parquet --full-refresh;\
	awslocal s3 sync /tmp/data_catalog/psa s3://datalake/psa;\
	meltano invoke dbt-duckdb run-operation elo_rollforward;\
	meltano run dbt-duckdb:build

server:
	meltano invoke dbt-osmosis server serve --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --host 127.0.0.1 --port 8581

register:
	meltano invoke dbt-osmosis server register-project --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --project-dir /workspaces/nba-monte-carlo/transform --target parquet
