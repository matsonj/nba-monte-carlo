MODEL (
  name nba.playoff_summary,
  kind VIEW
);

WITH cte_playoffs_r1 AS (
    SELECT
        winning_team,
        COUNT(*) AS made_playoffs
    FROM nba.initialize_seeding
    GROUP BY ALL
),

cte_playoffs_r2 AS (
    SELECT
        winning_team,
        COUNT(*) AS made_conf_semis
    FROM nba.playoff_sim_r1
    GROUP BY ALL
),

cte_playoffs_r3 AS (
    SELECT 
        winning_team,
        COUNT(*) AS made_conf_finals
    FROM nba.playoff_sim_r2
    GROUP BY ALL
),

cte_playoffs_r4 AS (
    SELECT 
        winning_team,
        COUNT(*) AS made_finals
    FROM nba.playoff_sim_r3
    GROUP BY ALL
),

cte_playoffs_finals AS (
    SELECT 
        winning_team,
        COUNT(*) AS won_finals
    FROM nba.playoff_sim_r4
    GROUP BY ALL
)

SELECT
    T.team,
    R1.made_playoffs,
    R2.made_conf_semis,
    R3.made_conf_finals,
    R4.made_finals,
    F.won_finals
FROM nba.teams T
LEFT JOIN cte_playoffs_r1 R1 ON R1.winning_team = T.team
LEFT JOIN cte_playoffs_r2 R2 ON R2.winning_team = T.team
LEFT JOIN cte_playoffs_r3 R3 ON R3.winning_team = T.team
LEFT JOIN cte_playoffs_r4 R4 ON R4.winning_team = T.team
LEFT JOIN cte_playoffs_finals F ON F.winning_team = T.team;
