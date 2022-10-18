





WITH  __dbt__cte__ratings as (






SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating

FROM '/tmp/storage/raw_team_ratings/*.parquet'

GROUP BY ALL
),  __dbt__cte__schedules as (






SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating

FROM '/tmp/storage/raw_schedule/*.parquet' S

LEFT JOIN __dbt__cte__ratings V ON V.team_long = S.visitorneutral
LEFT JOIN __dbt__cte__ratings H ON H.team_long = S.homeneutral
WHERE S.type = 'reg_season'
GROUP BY ALL
UNION ALL
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

FROM '/tmp/storage/raw_schedule/*.parquet' AS S

WHERE S.type <> 'reg_season'
GROUP BY ALL
),  __dbt__cte__reg_season_simulator as (
-- depends-on: "main"."main"."random_num_gen"







SELECT 
    R.scenario_id,
    S.*,
    ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team
FROM __dbt__cte__schedules S
    
    LEFT JOIN '/tmp/storage/random_num_gen.parquet'
    R ON R.game_id = S.game_id
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