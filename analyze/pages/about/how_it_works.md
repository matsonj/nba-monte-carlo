# How it works

## Env. config
- devcontainer (python + node)
- meltano then handles all the python environment stuff

## Extract
- singer taps / meltano extractors 
- using spreadsheets anywhere tap because it can grab data from basically anywhere
- leveraging meltano mappers to enhance data with timestamps (for later)
- invoked with ```meltano run tap-spreadsheets-anywhere mapper-timestamps target-parquet```

## Load
- using singer target / meltano loaders
- using parquet target as for openness & portability
- considered target-duckdb but ran into a few issues

## Transform
- using dbt-duckdb + external tables
- data can be consumed post transformation from either duckdb file or from the output parquet files
- in all other ways, it is a normal dbt-core project
- invoked with ```meltano invoke dbt-duckdb build```

## Analyze
- using evidence.dev
- can handle some final transforms as well, queries are staged and pages are built out in markdown
- because evidence doesn't support pathing, have to copy files into the evidence directory
- invoked with ```npm run dev``` and soon from meltano as well

## Other
- take a look at the [makefile](https://github.com/matsonj/nba-monte-carlo/blob/master/Makefile) and the [deploy github action](https://github.com/matsonj/nba-monte-carlo/blob/master/.github/workflows/deploy_on_netlify.yml) to see how the pieces fit together in prod.