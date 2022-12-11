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
)

SELECT
    T.team,
    COALESCE(W.wins, 0) AS wins,
    COALESCE(L.losses, 0) AS losses
FROM __dbt__cte__teams T
LEFT JOIN cte_wins W ON W.winning_team = T.team
LEFT JOIN cte_losses L ON L.losing_team = T.Team