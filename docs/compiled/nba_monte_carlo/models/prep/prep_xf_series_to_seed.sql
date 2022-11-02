with __dbt__cte__raw_xf_series_to_seed as (
SELECT *
FROM '/tmp/data_catalog/psa/xf_series_to_seed/*.parquet'
)SELECT *
FROM __dbt__cte__raw_xf_series_to_seed
GROUP BY ALL