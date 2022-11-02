
    
    

with __dbt__cte__raw_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
),  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM __dbt__cte__raw_nba_elo_latest
GROUP BY ALL
),  __dbt__cte__prep_latest_ratings as (
WITH cte_team1 AS (
    SELECT
        date,
        team1,
        elo1_post
    FROM __dbt__cte__prep_nba_elo_latest
    WHERE elo1_post IS NOT NULL
),

cte_team2 AS (
    SELECT
        date,
        team2,
        elo2_post
    FROM __dbt__cte__prep_nba_elo_latest
    WHERE elo1_post IS NOT NULL
),

cte_combined AS (
    SELECT * FROM cte_team1
    UNION ALL
    SELECT * from cte_team2
),

cte_days_ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY team1 ORDER BY date DESC) AS rating_id
    FROM cte_combined
)

SELECT
    team1 AS team,
    elo1_post AS elo_rating,
    True AS latest_ratings
FROM cte_days_ranked
WHERE rating_id = 1
)select
    team as unique_field,
    count(*) as n_records

from __dbt__cte__prep_latest_ratings
where team is not null
group by team
having count(*) > 1


