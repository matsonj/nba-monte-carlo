with __dbt__cte__raw_xf_series_to_seed as (
SELECT *
FROM '/tmp/data_catalog/psa/xf_series_to_seed/*.parquet'
),  __dbt__cte__prep_xf_series_to_seed as (
SELECT *
FROM __dbt__cte__raw_xf_series_to_seed
GROUP BY ALL
)SELECT
    series_id,
    seed
FROM __dbt__cte__prep_xf_series_to_seed