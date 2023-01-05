WITH cte_wins AS (
    SELECT 
        winning_team,
        COUNT(*) as wins
    FROM "main"."main"."latest_results"
    GROUP BY ALL
),

cte_losses AS (
    SELECT 
        losing_team,
        COUNT(*) as losses
    FROM "main"."main"."latest_results"
    GROUP BY ALL
)

SELECT
    T.team,
    COALESCE(W.wins, 0) AS wins,
    COALESCE(L.losses, 0) AS losses
FROM "main"."main"."teams" T
LEFT JOIN cte_wins W ON W.winning_team = T.team
LEFT JOIN cte_losses L ON L.losing_team = T.Team