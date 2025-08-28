# NBA Monte Carlo - Agent Instructions

## Build/Test/Lint Commands
- **Full build**: `make build` (sets up venv, installs deps, configures dbt and Evidence)
- **Run pipeline**: `make run` (executes DLT → DBT → Evidence sources)  
- **Development server**: `make dev` (Evidence dev server on 0.0.0.0)
- **Production build**: `make serve` (builds and serves Evidence static site)
- **DBT commands**: `cd transform && ../.venv/bin/dbt build` (or test, run, docs)
- **Single DBT model**: `cd transform && ../.venv/bin/dbt run -s model_name`
- **Tagged models**: `cd transform && ../.venv/bin/dbt build -s tag:nba`

## Architecture
This is a "Modern Data Stack in a Box" with components:
- **dlt/**: Data ingestion pipeline (fetches NBA API data to filesystem/CSV)
- **transform/**: DBT models for data transformation (uses DuckDB, supports Python models)
- **evidence/**: Static site BI dashboard (Evidence.dev framework)
- **data/**: Raw data and parquet catalog for external tables
- **sqlmesh/** and **malloy/**: Alternative transformation/query frameworks

Data flows: API → DLT (CSV) → DBT (DuckDB) → Evidence (static site)

## Code Style
- **Python**: Use pandas, polars, numpy. DBT Python models define `model(dbt, sess)` function
- **SQL**: Use `{{ ref("model_name") }}` for DBT refs, snake_case naming
- **File organization**: Models organized by sport (nba/nfl) and layer (raw/prep/simulator/analysis)
- **Variables**: Configure via dbt_project.yml vars (scenarios, include_actuals, latest_ratings, etc.)
- **Dependencies**: Use uv for Python package management, npm for Evidence
