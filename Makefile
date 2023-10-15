build:
	pip install -r requirements.txt
	cd evidence && npm install @evidence-dev/evidence@latest @evidence-dev/core-components@latest
	cd transform && dbt deps
	mkdir -p data/data_catalog/raw
	mkdir -p data/data_catalog/prep
	mkdir -p data/data_catalog/simulator
	mkdir -p data/data_catalog/analysis

run:
	cd transform && dbt build

serve:
	cd evidence && npm run dev -- --host 0.0.0.0

docker-build:
	docker build -t mdsbox .

evidence-run:
	meltano invoke evidence dev

evidence-run-old:
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
