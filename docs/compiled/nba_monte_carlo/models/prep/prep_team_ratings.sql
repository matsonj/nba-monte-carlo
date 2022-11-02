with __dbt__cte__raw_team_ratings as (
SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
)SELECT *
FROM __dbt__cte__raw_team_ratings