---
title: how it works
---

## Env. config
- devcontainer (python + node)

## Extract
- tbd - extraction is via "copy + paste" today - although looking to implement dlthub "soon"

## Load
- using seeds in dbt - but related to extract above, have the same considerations

## Transform
- using dbt-duckdb + external tables
- data can be consumed post transformation from either duckdb file or from the output parquet files
- in all other ways, it is a normal dbt-core project
- invoked with ```make run```

## Analyze
- using evidence.dev
- can handle some final transforms as well, queries are staged and pages are built out in markdown
- because evidence doesn't support pathing, have to copy files into the evidence directory
- invoked with ```make dev```

## Other
- take a look at the [makefile](https://github.com/matsonj/nba-monte-carlo/blob/master/Makefile) and the [deploy github action](https://github.com/matsonj/nba-monte-carlo/blob/master/.github/workflows/deploy_on_netlify.yml) to see how the pieces fit together in prod.