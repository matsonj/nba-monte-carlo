pipeline:
	python3 -m pip install --user pipx ;\
	python3 -m pipx ensurepath ;\
	source ~/.bashrc ;\
	pipx install meltano ;\
	meltano install ;\
	meltano run tap-spreadsheets-anywhere target-duckdb dbt:build