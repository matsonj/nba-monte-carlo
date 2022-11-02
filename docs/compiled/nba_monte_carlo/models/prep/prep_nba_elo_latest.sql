with __dbt__cte__raw_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
)SELECT *
FROM __dbt__cte__raw_nba_elo_latest
GROUP BY ALL