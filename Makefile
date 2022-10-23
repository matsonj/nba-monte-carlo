build:
	meltano install

run:
	meltano run tap-spreadsheets-anywhere target-duckdb --full-refresh dbt-duckdb:build

parquet:
	meltano run tap-spreadsheets-anywhere target-parquet --full-refresh;\
	meltano invoke dbt-duckdb build --target parquet

pipeline:
	meltano run tap-spreadsheets-anywhere target-duckdb;\
	meltano invoke dbt-duckdb build -s +schedules,+latest_results;\
	meltano invoke dbt-duckdb run-operation elo_rollforward;\
	meltano run dbt-duckdb:build