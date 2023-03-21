build:
	meltano install

pipeline:
	meltano run tap-spreadsheets-anywhere add-timestamps target-parquet
	mkdir -p data/data_catalog/conformed
	mkdir -p data/data_catalog/prep
	mkdir -p data/data_catalog/raw
	meltano invoke dbt-duckdb deps
	meltano invoke dbt-duckdb run-operation elo_rollforward
	meltano invoke dbt-duckdb build

docker-build:
	docker build -t mdsbox .

superset-visuals:
	meltano install utility superset
	meltano invoke superset fab create-admin --username admin --firstname lebron --lastname james --email admin@admin.org --password password
	meltano invoke superset import-datasources -p visuals/datasources.yml
	meltano invoke superset import-dashboards -p visuals/dashboards.json
	meltano invoke superset:ui

docker-run-superset:
	docker run \
		--publish 8088:8088 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make pipeline superset-visuals

evidence-build:
	cd analyze && npm i -force
	cd analyze && mkdir -p data_catalog
	cp -r data/data_catalog/* analyze/data_catalog
	cp analyze/data_catalog/mdsbox.db analyze/

evidence-run:
	cd analyze && npm run dev -- --host 0.0.0.0

evidence-visuals:
	make evidence-build
	make evidence-run

docker-run-evidence:
		docker run \
		--publish 3000:3000 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make pipeline evidence-visuals

rill-install:
	curl -s https://cdn.rilldata.com/install.sh | bash

rill-build:
	mkdir -p rill
	cd rill && rill init
	cd rill && for file in ../data/data_catalog/conformed/*.parquet; do rill source add $$file; done

rill-run:
	cd rill && rill start

rill-visuals:
	make rill-install
	make rill-build
	make rill-run

docker-run-rill:
		docker run \
		--publish 9009:9009 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make pipeline rill-visuals	