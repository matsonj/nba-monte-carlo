build:
	meltano install

run:
	meltano run tap-spreadsheets-anywhere target-duckdb --full-refresh dbt-duckdb:build

parquet:
	meltano run tap-spreadsheets-anywhere target-parquet --full-refresh;\
	mkdir /tmp/data_catalog/conformed;\
	mkdir /tmp/data_catalog/prep;\
	mkdir /tmp/data_catalog/raw;\
	meltano invoke dbt-duckdb run-operation elo_rollforward --target parquet;\
	meltano invoke dbt-duckdb build --target parquet

pipeline:
	meltano run tap-spreadsheets-anywhere target-duckdb --full-refresh;\
	meltano invoke dbt-duckdb run-operation elo_rollforward;\
	meltano run dbt-duckdb:build

server:
	meltano invoke dbt-osmosis server serve --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --host 127.0.0.1 --port 8581

register:
	meltano invoke dbt-osmosis server register-project --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --project-dir /workspaces/nba-monte-carlo/transform --target parquet