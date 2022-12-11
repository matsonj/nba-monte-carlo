

    with __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
)SELECT COALESCE(COUNT(*),0) AS records
    FROM __dbt__cte__prep_nba_elo_latest
    HAVING COUNT(*) = 0

