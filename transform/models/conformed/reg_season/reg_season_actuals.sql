{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

WITH cte_wins AS (
    SELECT 
        winning_team,
        COUNT(*) as wins
    FROM {{ ref( 'latest_results' ) }}
    GROUP BY ALL
),

cte_losses AS (
    SELECT 
        losing_team,
        COUNT(*) as losses
    FROM {{ ref( 'latest_results' ) }}
    GROUP BY ALL
)

SELECT
    T.team,
    W.wins,
    L.losses
FROM {{ ref( 'teams' ) }} T
LEFT JOIN cte_wins W ON W.winning_team = T.team
LEFT JOIN cte_losses L ON L.losing_team = T.Team
