select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



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
)select series_id
from __dbt__cte__xf_series_to_seed
where series_id is null



      
    ) dbt_internal_test