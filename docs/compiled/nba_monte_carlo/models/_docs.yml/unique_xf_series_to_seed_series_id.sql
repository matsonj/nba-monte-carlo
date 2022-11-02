
    
    

with __dbt__cte__raw_xf_series_to_seed as (
SELECT *
FROM '/tmp/data_catalog/psa/xf_series_to_seed/*.parquet'
),  __dbt__cte__prep_xf_series_to_seed as (
SELECT *
FROM __dbt__cte__raw_xf_series_to_seed
GROUP BY ALL
),  __dbt__cte__xf_series_to_seed as (
SELECT
    series_id,
    seed
FROM __dbt__cte__prep_xf_series_to_seed
)select
    series_id as unique_field,
    count(*) as n_records

from __dbt__cte__xf_series_to_seed
where series_id is not null
group by series_id
having count(*) > 1


