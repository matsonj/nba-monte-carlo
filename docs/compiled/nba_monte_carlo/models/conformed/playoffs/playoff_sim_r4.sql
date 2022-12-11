

WITH  __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
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
),  __dbt__cte__prep_schedule as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_schedule_2023/*.parquet'
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
),  __dbt__cte__prep_xf_series_to_seed as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/xf_series_to_seed/*.parquet'
GROUP BY ALL
),  __dbt__cte__xf_series_to_seed as (
SELECT
    series_id,
    seed
FROM __dbt__cte__prep_xf_series_to_seed
),cte_playoff_sim AS (
    
-- depends-on: "main"."main"."random_num_gen"

WITH cte_step_1 AS (
    SELECT
      R.scenario_id,
      S.game_id,
      S.series_id,
      S.visiting_team AS visitor_key,
      S.home_team AS home_key,
      EV.winning_team AS visiting_team,
      EV.elo_rating AS visiting_team_elo_rating,
      EH.winning_team AS home_team,
      EH.elo_rating AS home_team_elo_rating,
      ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating )::real/400)+1))) * 10000 as home_team_win_probability,
      R.rand_result,
      CASE
         WHEN ( 1 - (1 / (10 ^ (-( EV.elo_rating - EH.elo_rating )::real/400)+1))) * 10000 >= R.rand_result THEN EH.winning_team
         ELSE EV.winning_team
      END AS winning_team 
    FROM __dbt__cte__schedules S
    
    LEFT JOIN "main"."main"."random_num_gen" R ON R.game_id = S.game_id
    LEFT JOIN  "main"."main"."playoff_sim_r3" EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN  "main"."main"."playoff_sim_r3" EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
    
    WHERE S.type =  'playoffs_r4' ),
cte_step_2 AS (
    SELECT step1.*,
        ROW_NUMBER() OVER (PARTITION BY scenario_id, series_id, winning_team  ORDER BY scenario_id, series_id, game_id ) AS series_result
    FROM cte_step_1 step1
),
cte_final_game AS (
    SELECT scenario_id,
        series_id,
        game_id
    FROM cte_step_2
    WHERE series_result = 4
)
SELECT step2.* 
FROM cte_step_2 step2
    INNER JOIN cte_final_game F ON F.scenario_id = step2.scenario_id 
        AND f.series_id = step2.series_id AND step2.game_id <= f.game_id
ORDER BY step2.scenario_id, 
    step2.series_id, 
    step2.game_id
)

SELECT
    E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed,
    0 AS sim_start_game_id
FROM cte_playoff_sim E
LEFT JOIN __dbt__cte__xf_series_to_seed XF ON XF.series_id = E.series_id
WHERE E.series_result = 4