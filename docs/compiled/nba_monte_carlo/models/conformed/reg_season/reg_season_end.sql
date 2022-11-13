

WITH  __dbt__cte__raw_nba_elo_latest as (
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
),  __dbt__cte__reg_season_simulator as (
SELECT 
    R.scenario_id,
    S.*,
    ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN LR.include_actuals = true THEN LR.winning_team
        WHEN ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team,
    COALESCE(LR.include_actuals, false) AS include_actuals
FROM __dbt__cte__schedules S
LEFT JOIN "main"."main"."random_num_gen" R ON R.game_id = S.game_id
LEFT JOIN __dbt__cte__latest_results LR ON LR.game_id = S.game_id
WHERE S.type = 'reg_season'
),cte_wins AS (
    SELECT
        S.scenario_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_conf
            ELSE S.visiting_conf
        END AS conf,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS elo_rating,
        COUNT(*) AS wins
    FROM __dbt__cte__reg_season_simulator S
    GROUP BY ALL
),

cte_ranked_wins AS (
    SELECT
        *,
        --no tiebreaker, so however row number handles order ties will need to be dealt with
        ROW_NUMBER() OVER (PARTITION BY scenario_id, conf ORDER BY wins DESC, winning_team DESC ) AS season_rank
    FROM cte_wins

),

cte_made_playoffs AS (
    SELECT
        *,
        CASE
            WHEN season_rank <= 10 THEN 1
            ELSE 0
        END AS made_playoffs,
        CASE
            WHEN season_rank BETWEEN 7 AND 10 THEN 1
            ELSE 0
        END AS made_play_in,
        conf || '-' || season_rank::text AS seed
    FROM cte_ranked_wins
)

SELECT *
FROM cte_made_playoffs