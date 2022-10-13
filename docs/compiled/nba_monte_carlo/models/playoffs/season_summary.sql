with __dbt__cte__ratings as (


SELECT team,
    team_long,
    conf,
    elo_rating::int as elo_rating
FROM '/tmp/storage/raw_team_ratings/*.parquet' S
GROUP BY ALL
),  __dbt__cte__teams as (


SELECT S.visitorneutral AS team_long,
    R.team
FROM '/tmp/storage/raw_schedule/*.parquet' S
    LEFT JOIN __dbt__cte__ratings R ON R.team_long = S.visitorneutral
GROUP BY ALL
),  __dbt__cte__playoff_summary as (
-- depends-on: "main"."main"."initialize_seeding"
-- depends-on: "main"."main"."playoff_sim_r1"
-- depends-on: "main"."main"."playoff_sim_r2"
-- depends-on: "main"."main"."playoff_sim_r3"
-- depends-on: "main"."main"."playoff_sim_r4"



WITH cte_playoffs_r1 AS (
    SELECT winning_team,
        COUNT(1) AS made_playoffs
    FROM '/tmp/storage/initialize_seeding.parquet'
    GROUP BY ALL
),
cte_playoffs_r2 AS (
    SELECT winning_team,
        COUNT(1) AS made_conf_semis
    FROM '/tmp/storage/playoff_sim_r1.parquet'
    GROUP BY ALL
),
cte_playoffs_r3 AS (
        SELECT winning_team,
        COUNT(1) AS made_conf_finals
    FROM '/tmp/storage/playoff_sim_r2.parquet'
    GROUP BY ALL
),
cte_playoffs_r4 AS (
        SELECT winning_team,
        COUNT(1) AS made_finals
    FROM '/tmp/storage/playoff_sim_r3.parquet'
    GROUP BY ALL
),
cte_playoffs_finals AS (
        SELECT winning_team,
        COUNT(1) AS won_finals
    FROM '/tmp/storage/playoff_sim_r4.parquet'
    GROUP BY ALL
)

SELECT T.team,
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
)-- depends-on: "main"."main"."reg_season_summary"



SELECT R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM '/tmp/storage/reg_season_summary.parquet' R
LEFT JOIN __dbt__cte__playoff_summary P ON P.team = R.team