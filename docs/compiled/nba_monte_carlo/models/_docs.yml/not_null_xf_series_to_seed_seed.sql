
    
    



with __dbt__cte__prep_xf_series_to_seed as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/xf_series_to_seed/*.parquet'
GROUP BY ALL
),  __dbt__cte__xf_series_to_seed as (
SELECT
    series_id,
    seed
FROM __dbt__cte__prep_xf_series_to_seed
)select seed
from __dbt__cte__xf_series_to_seed
where seed is null


