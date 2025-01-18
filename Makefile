build:
	uv venv && uv sync
	cd transform && ../.venv/bin/dbt deps
	cd evidence && npm install
	mkdir -p data/data_catalog/raw
	mkdir -p data/data_catalog/prep
	mkdir -p data/data_catalog/simulator
	mkdir -p data/data_catalog/analysis

run:
	cd dlt && ../.venv/bin/python3 nba_pipeline.py
	cd transform && ../.venv/bin/dbt build
	cd evidence && npm run sources

dev:
	cd evidence && npm run dev -- --host 0.0.0.0

serve:
	rm -rf evidence/build
	cd evidence && npm run build
	cd evidence && npm i -g http-server
	cd evidence && npx http-server ./build

evidence-build:
	cd evidence && npm run build

docker-build:
	docker build -t mdsbox .

docker-run-evidence:
		docker run \
		--publish 3000:3000 \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make run serve

docker-dev:
		docker run \
		--publish 3000:3000 \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make run dev

DATES = $(shell python -c 'from datetime import datetime, timedelta; start_date = datetime(2023, 10, 24); end_date = datetime(2024, 4, 14); date_list = [start_date + timedelta(days=x) for x in range((end_date - start_date).days + 1)]; print(" ".join(date.strftime("%Y-%m-%d") for date in date_list))')

dbt-run-backfill:
	@for date in $(DATES); do \
		echo "Running dbt build for $$date"; \
		(cd transform && ../.venv/bin/dbt build -s tag:nba --vars "nba_start_date: $$date"); \
	done
