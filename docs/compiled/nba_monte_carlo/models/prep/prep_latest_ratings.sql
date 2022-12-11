WITH  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
),cte_team1 AS (
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