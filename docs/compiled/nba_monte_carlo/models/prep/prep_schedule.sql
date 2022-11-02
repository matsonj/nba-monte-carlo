with __dbt__cte__raw_schedule as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
)SELECT *
FROM __dbt__cte__raw_schedule