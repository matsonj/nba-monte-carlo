

WITH  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
),  __dbt__cte__latest_results as (
SELECT
    (_smart_source_lineno - 1)::int AS game_id,
    team1 AS home_team, 
    score1 AS home_team_score,
    team2 AS visiting_team,
    score2 AS visiting_team_score,
    date,
    CASE 
        WHEN score1 > score2 THEN team1
        ELSE team2
    END AS winning_team,
    CASE 
        WHEN score1 > score2 THEN team2
        ELSE team1
    END AS losing_team,
    True AS include_actuals
FROM __dbt__cte__prep_nba_elo_latest
WHERE score1 IS NOT NULL
GROUP BY ALL
),  __dbt__cte__prep_schedule as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_schedule_2023/*.parquet'
),  __dbt__cte__prep_team_ratings as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/team_ratings/*.parquet'
),  __dbt__cte__prep_elo_post as (
SELECT
    *,
    True AS latest_ratings
FROM  '/workspaces/nba-monte-carlo/data/data_catalog/prep/elo_post.parquet'
),  __dbt__cte__ratings as (
SELECT
    orig.team,
    orig.team_long,
    orig.conf,
    CASE
        WHEN latest.latest_ratings = true AND latest.elo_rating IS NOT NULL THEN latest.elo_rating
        ELSE orig.elo_rating
    END AS elo_rating,
    orig.elo_rating AS original_rating,
    orig.win_total
FROM __dbt__cte__prep_team_ratings orig
LEFT JOIN __dbt__cte__prep_elo_post latest ON latest.team = orig.team
GROUP BY ALL
),  __dbt__cte__teams as (
SELECT
    S.visitorneutral AS team_long,
    R.team
FROM __dbt__cte__prep_schedule S
LEFT JOIN __dbt__cte__ratings AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL
),cte_wins AS (
    SELECT 
        winning_team,
        COUNT(*) as wins
    FROM __dbt__cte__latest_results
    GROUP BY ALL
),

cte_losses AS (
    SELECT 
        losing_team,
        COUNT(*) as losses
    FROM __dbt__cte__latest_results
    GROUP BY ALL
),

cte_favored_wins AS (
    SELECT 
        LR.winning_team,
        COUNT(*) as wins
    FROM __dbt__cte__latest_results LR
    INNER JOIN "main"."main"."prep_results_log" R ON R.game_id = LR.game_id
        AND R.favored_team = LR.winning_team
    GROUP BY ALL
),

cte_favored_losses AS (
    SELECT 
        LR.losing_team,
        COUNT(*) as losses
    FROM __dbt__cte__latest_results LR
    INNER JOIN "main"."main"."prep_results_log" R ON R.game_id = LR.game_id
        AND R.favored_team = LR.losing_team
    GROUP BY ALL
),

cte_avg_opponent_wins AS (
    SELECT 
        LR.winning_team,
        COUNT(*) as wins
    FROM __dbt__cte__latest_results LR
    INNER JOIN "main"."main"."prep_results_log" R ON R.game_id = LR.game_id
        AND ( (LR.winning_team = R.home_team AND R.visiting_team_above_avg = 1)
            OR (LR.winning_team = R.visiting_team AND R.home_team_above_avg = 1) )
    GROUP BY ALL
),

cte_avg_opponent_losses AS (
    SELECT 
        LR.losing_team,
        COUNT(*) as losses
    FROM __dbt__cte__latest_results LR
    INNER JOIN "main"."main"."prep_results_log" R ON R.game_id = LR.game_id
        AND ( (LR.losing_team = R.visiting_team AND R.home_team_above_avg = 1)
            OR (LR.losing_team = R.home_team AND R.visiting_team_above_avg = 1) )
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
    COALESCE(L.losses, 0) - COALESCE(AL.losses, 0) AS losses_vs_bad_teams 
FROM __dbt__cte__teams T
LEFT JOIN cte_wins W ON W.winning_team = T.team
LEFT JOIN cte_losses L ON L.losing_team = T.Team
LEFT JOIN cte_favored_wins FW ON FW.winning_team = T.team
LEFT JOIN cte_favored_losses FL ON FL.losing_team = T.Team
LEFT JOIN cte_avg_opponent_wins AW ON AW.winning_team = T.Team
LEFT JOIN cte_avg_opponent_losses AL ON AL.losing_team = T.team