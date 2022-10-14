build:
	meltano install

run:
	meltano run tap-spreadsheets-anywhere target-duckdb dbt-duckdb:build
