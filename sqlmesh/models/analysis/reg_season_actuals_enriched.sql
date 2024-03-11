MODEL (
  name nba.reg_season_actuals_enriched,
  kind FULL
);

WITH cte_wins AS (
    SELECT 
        winning_team,
        COUNT(*) as wins
    FROM nba.latest_results
    GROUP BY ALL
),

cte_losses AS (
    SELECT 
        losing_team,
        COUNT(*) as losses
    FROM nba.latest_results
    GROUP BY ALL
),


cte_favored_wins AS (
    SELECT 
        LR.winning_team,
        COUNT(*) as wins
    FROM nba.latest_results LR
    INNER JOIN nba.results_log R ON R.game_id = LR.game_id
        AND R.favored_team = LR.winning_team
    GROUP BY ALL
),

cte_favored_losses AS (
    SELECT 
        LR.losing_team,
        COUNT(*) as losses
    FROM nba.latest_results LR
    INNER JOIN nba.results_log R ON R.game_id = LR.game_id
        AND R.favored_team = LR.losing_team
    GROUP BY ALL
),

cte_avg_opponent_wins AS (
    SELECT 
        LR.winning_team,
        COUNT(*) as wins
    FROM nba.latest_results LR
    INNER JOIN nba.results_log R ON R.game_id = LR.game_id
        AND ( (LR.winning_team = R.home_team AND R.visiting_team_above_avg = 1)
            OR (LR.winning_team = R.visiting_team AND R.home_team_above_avg = 1) )
    GROUP BY ALL
),

cte_avg_opponent_losses AS (
    SELECT 
        LR.losing_team,
        COUNT(*) as losses
    FROM nba.latest_results LR
    INNER JOIN nba.results_log R ON R.game_id = LR.game_id
        AND ( (LR.losing_team = R.visiting_team AND R.home_team_above_avg = 1)
            OR (LR.losing_team = R.home_team AND R.visiting_team_above_avg = 1) )
    GROUP BY ALL
),

cte_home_wins AS (
    SELECT 
        LR.home_team,
        COUNT(*) as wins
    FROM nba.latest_results LR
    WHERE LR.home_team = LR.winning_team
    GROUP BY ALL   
),

cte_home_losses AS (
    SELECT 
        LR.home_team,
        COUNT(*) as losses
    FROM nba.latest_results LR
    WHERE LR.home_team = LR.losing_team  
    GROUP BY ALL  
)

SELECT
    T.team,
    COALESCE(W.wins, 0) AS wins,
    COALESCE(L.losses, 0) AS losses,
    COALESCE(FW.wins, 0) AS wins_as_favorite,
    COALESCE(FL.losses, 0) AS losses_as_favorite,
    COALESCE(W.wins, 0) - COALESCE(FW.wins, 0) AS wins_as_underdog,
    COALESCE(L.losses, 0) - COALESCE(FL.losses, 0) AS losses_as_underdog,
    COALESCE(AW.wins,0) AS wins_vs_good_teams,
    COALESCE(AL.losses,0) AS losses_vs_good_teams,
    COALESCE(W.wins, 0) - COALESCE(AW.wins, 0) AS wins_vs_bad_teams,
    COALESCE(L.losses, 0) - COALESCE(AL.losses, 0) AS losses_vs_bad_teams,
    COALESCE(HW.wins,0) AS home_wins,
    COALESCE(HL.losses,0) AS home_losses,
    COALESCE(W.wins, 0) - COALESCE(HW.wins, 0) AS away_wins,
    COALESCE(L.losses, 0) - COALESCE(HL.losses, 0) AS away_losses
FROM nba.teams T
LEFT JOIN cte_wins W ON W.winning_team = T.team_long
LEFT JOIN cte_losses L ON L.losing_team = T.Team_long
LEFT JOIN cte_favored_wins FW ON FW.winning_team = T.Team_long
LEFT JOIN cte_favored_losses FL ON FL.losing_team = T.Team_long
LEFT JOIN cte_avg_opponent_wins AW ON AW.winning_team = T.Team_long
LEFT JOIN cte_avg_opponent_losses AL ON AL.losing_team = T.Team_long
LEFT JOIN cte_home_wins HW ON HW.home_team = T.Team_long
LEFT JOIN cte_home_losses HL ON HL.home_team = T.Team_long;