

    WITH  __dbt__cte__raw_team_ratings as (
SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
),  __dbt__cte__prep_team_ratings as (
SELECT *
FROM __dbt__cte__raw_team_ratings
),  __dbt__cte__prep_elo_post as (
SELECT
    *,
    True AS latest_ratings
FROM '/tmp/data_catalog/prep/elo_post.parquet'
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
),  __dbt__cte__vegas_wins as (
SELECT
    team,
    win_total
FROM __dbt__cte__ratings
GROUP BY ALL
),  __dbt__cte__raw_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
),  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM __dbt__cte__raw_nba_elo_latest
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
),  __dbt__cte__raw_schedule as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
),  __dbt__cte__prep_schedule as (
SELECT *
FROM __dbt__cte__raw_schedule
),  __dbt__cte__teams as (
SELECT
    S.visitorneutral AS team_long,
    R.team
FROM __dbt__cte__prep_schedule S
LEFT JOIN __dbt__cte__ratings AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL
),  __dbt__cte__reg_season_actuals as (
WITH cte_wins AS (
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
),cte_summary AS (
    SELECT
        winning_team AS team,
        E.conf,
        ROUND(AVG(wins),1) AS avg_wins,
        V.win_total AS vegas_wins,
        ROUND(AVG(V.win_total) - AVG(wins), 1) AS elo_vs_vegas,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_5th,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_95th,
        COUNT(*) FILTER (WHERE made_playoffs = 1 AND made_play_in = 0) AS made_postseason,
        COUNT(*) FILTER (WHERE made_play_in = 1) AS made_play_in,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_5th,
        ROUND(AVG(season_rank), 1) AS avg_seed,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_95th
    FROM "main"."main"."reg_season_end" E
    LEFT JOIN __dbt__cte__vegas_wins V ON V.team = E.winning_team
    GROUP BY ALL
    )

SELECT 
    C.team,
    C.conf,
    A.wins || ' - ' || A.losses AS record,
    C.avg_wins,
    C.vegas_wins,
    c.elo_vs_vegas,
    C.wins_5th || ' to ' || C.wins_95th AS win_range,
    C.seed_5th || ' to ' || C.seed_95th AS seed_range,
    c.made_postseason,
    c.made_play_in
FROM cte_summary C
LEFT JOIN __dbt__cte__reg_season_actuals A ON A.team = C.team