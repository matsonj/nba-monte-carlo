with __dbt__cte__ratings as (






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
)-- depends-on: "main"."main"."random_num_gen"







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