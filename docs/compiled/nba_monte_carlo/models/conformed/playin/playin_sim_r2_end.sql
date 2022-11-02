with __dbt__cte__raw_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
),  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM __dbt__cte__raw_nba_elo_latest
GROUP BY ALL
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
),  __dbt__cte__reg_season_schedule as (
SELECT
    (S._smart_source_lineno - 1)::int AS game_id,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM __dbt__cte__prep_nba_elo_latest AS S
LEFT JOIN __dbt__cte__ratings V ON V.team = S.team2
LEFT JOIN __dbt__cte__ratings H ON H.team = S.team1
GROUP BY ALL
),  __dbt__cte__raw_schedule as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
),  __dbt__cte__prep_schedule as (
SELECT *
FROM __dbt__cte__raw_schedule
),  __dbt__cte__post_season_schedule as (
SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM __dbt__cte__prep_schedule AS S
WHERE S.type <> 'reg_season'
GROUP BY ALL
),  __dbt__cte__schedules as (
SELECT
    *
FROM __dbt__cte__reg_season_schedule
UNION ALL
SELECT
    *
FROM __dbt__cte__post_season_schedule
),  __dbt__cte__playin_sim_r1 as (
SELECT
    R.scenario_id,
    S.game_id,
    EV.conf AS conf,
    EV.winning_team AS visiting_team,
    EV.elo_rating AS visiting_team_elo_rating,
    EH.winning_team AS home_team,
    EH.elo_rating AS home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 AS home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 >= R.rand_result THEN EH.winning_team
        ELSE EV.winning_team
    END AS winning_team 
FROM __dbt__cte__schedules S
    LEFT JOIN "main"."main_export"."random_num_gen" R ON R.game_id = S.game_id
    LEFT JOIN "main"."main_export"."reg_season_end" EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN "main"."main_export"."reg_season_end" EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
WHERE S.type = 'playin_r1'
),  __dbt__cte__playin_sim_r1_end as (
WITH cte_playin_details AS (
    SELECT
        S.scenario_id,
        S.game_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS winning_team_elo_rating,
        S.conf AS conf,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_team
            ELSE S.home_team
        END AS losing_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_team_elo_rating
            ELSE S.home_team_elo_rating
        END AS losing_team_elo_rating,
        CASE
            WHEN S.game_id IN (1231, 1234) THEN 'winner advance'
            WHEN S.game_id IN (1232, 1235) THEN 'loser eliminated'
        END AS result
    FROM __dbt__cte__playin_sim_r1 S
)

SELECT
    *,
    CASE
        WHEN game_id IN (1231, 1234) THEN losing_team
        WHEN game_id IN (1232, 1235) THEN winning_team
    END AS remaining_team
FROM cte_playin_details
),  __dbt__cte__playin_sim_r2 as (
SELECT 
    R.scenario_id,
    S.game_id,
    S.home_team[7:] AS home_team_id,
    S.visiting_team[8:] AS visiting_team_id,
    EV.conf AS conf,
    EV.remaining_team AS visiting_team,
    EV.winning_team_elo_rating AS visiting_team_elo_rating,
    EH.remaining_team AS home_team,
    EH.losing_team_elo_rating AS home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 >= R.rand_result THEN EH.remaining_team
        ELSE EV.remaining_team
    END AS winning_team 
FROM __dbt__cte__schedules S
    LEFT JOIN "main"."main_export"."random_num_gen" R ON R.game_id = S.game_id
    LEFT JOIN __dbt__cte__playin_sim_r1_end EH ON R.scenario_id = EH.scenario_id AND EH.game_id = S.home_team[7:]
    LEFT JOIN __dbt__cte__playin_sim_r1_end EV ON R.scenario_id = EV.scenario_id AND EV.game_id = S.visiting_team[8:]
WHERE S.type = 'playin_r2'
)SELECT
    P1.scenario_id,
    P1.conf,
    P1.winning_team,
    P1.conf || '-7' AS seed,
    P1.winning_team_elo_rating
FROM __dbt__cte__playin_sim_r1_end P1
WHERE P1.result = 'winner advance'
UNION ALL
SELECT
    P2.scenario_id,
    P2.conf AS conf,
    P2.winning_team,
    P2.conf || '-8' AS seed,
    CASE
        WHEN P2.winning_team = P2.home_team THEN P2.home_team_elo_rating
        ELSE P2.visiting_team_elo_rating
    END AS elo_rating
FROM __dbt__cte__playin_sim_r2 P2