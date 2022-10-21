build:
	meltano install

run:
	meltano run tap-spreadsheets-anywhere target-duckdb dbt-duckdb:build

parquet:
	meltano run tap-spreadsheets-anywhere target-parquet ;\
	meltano invoke dbt-duckdb build --target parquet
