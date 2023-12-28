build:
	pip install -r requirements.txt
	pipx ensurepath
	pipx install meltano==3.1.0
	meltano install
	meltano invoke dbt-duckdb deps
	meltano invoke evidence npm install
	mkdir -p data/data_catalog/raw
	mkdir -p data/data_catalog/prep
	mkdir -p data/data_catalog/simulator
	mkdir -p data/data_catalog/analysis

run:
	meltano invoke dbt-duckdb build
	meltano invoke evidence npm run sources

dev:
	meltano invoke evidence dev

serve:
	cd evidence && npm run build
	cd evidence && npm i -g http-server
	cd evidence && npx http-server ./build

evidence-build:
	meltano invoke evidence build

docker-build:
	docker build -t mdsbox .

docker-run-evidence:
		docker run \
		--publish 3000:3000 \
	 	--env MELTANO_CLI_LOG_LEVEL=WARNING \
		--env MDS_SCENARIOS=10000 \
		--env MDS_INCLUDE_ACTUALS=true \
		--env MDS_LATEST_RATINGS=true \
		--env MDS_ENABLE_EXPORT=true \
		--env ENVIRONMENT=docker \
		mdsbox make run serve