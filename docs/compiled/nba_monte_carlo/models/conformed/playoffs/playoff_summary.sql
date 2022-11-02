WITH  __dbt__cte__raw_schedule as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
),  __dbt__cte__prep_schedule as (
SELECT *
FROM __dbt__cte__raw_schedule
),  __dbt__cte__raw_team_ratings as (
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
),  __dbt__cte__teams as (
SELECT
    S.visitorneutral AS team_long,
    R.team
FROM __dbt__cte__prep_schedule S
LEFT JOIN __dbt__cte__ratings AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL
),cte_playoffs_r1 AS (
    SELECT
        winning_team,
        COUNT(*) AS made_playoffs
    FROM "main"."main_export"."initialize_seeding"
    GROUP BY ALL
),

cte_playoffs_r2 AS (
    SELECT
        winning_team,
        COUNT(*) AS made_conf_semis
    FROM "main"."main_export"."playoff_sim_r1"
    GROUP BY ALL
),

cte_playoffs_r3 AS (
    SELECT 
        winning_team,
        COUNT(*) AS made_conf_finals
    FROM "main"."main_export"."playoff_sim_r2"
    GROUP BY ALL
),

cte_playoffs_r4 AS (
    SELECT 
        winning_team,
        COUNT(*) AS made_finals
    FROM "main"."main_export"."playoff_sim_r3"
    GROUP BY ALL
),

cte_playoffs_finals AS (
    SELECT 
        winning_team,
        COUNT(*) AS won_finals
    FROM "main"."main_export"."playoff_sim_r4"
    GROUP BY ALL
)

SELECT
    T.team,
    R1.made_playoffs,
    R2.made_conf_semis,
    R3.made_conf_finals,
    R4.made_finals,
    F.won_finals
FROM __dbt__cte__teams T
LEFT JOIN cte_playoffs_r1 R1 ON R1.winning_team = T.team
LEFT JOIN cte_playoffs_r2 R2 ON R2.winning_team = T.team
LEFT JOIN cte_playoffs_r3 R3 ON R3.winning_team = T.team
LEFT JOIN cte_playoffs_r4 R4 ON R4.winning_team = T.team
LEFT JOIN cte_playoffs_finals F ON F.winning_team = T.team