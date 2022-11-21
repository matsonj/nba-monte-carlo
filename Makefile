build:
	meltano install
	mkdir -p /tmp/data_catalog/conformed
	mkdir -p /tmp/data_catalog/prep
	mkdir -p /tmp/data_catalog/raw

pipeline:
	meltano run tap-spreadsheets-anywhere target-parquet
	meltano invoke dbt-duckdb deps
	meltano invoke dbt-duckdb run-operation elo_rollforward
	meltano invoke dbt-duckdb build

visuals:
	meltano invoke superset import-datasources -p visuals/dashboards.json
	meltano invoke superset import-dashboards -p visuals/dashboards.json

server:
	meltano invoke dbt-osmosis server serve --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --host 127.0.0.1 --port 8581

register:
	meltano invoke dbt-osmosis server register-project --profiles-dir /workspaces/nba-monte-carlo/transform/profiles/duckdb --project-dir /workspaces/nba-monte-carlo/transform

docker-build:
	docker build -t mdsbox .

docker-run:
	docker run \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=100 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		mdsbox make pipeline
