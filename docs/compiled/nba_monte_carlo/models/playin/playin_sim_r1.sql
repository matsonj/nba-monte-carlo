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
-- depends-on: "main"."main"."reg_season_end"





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
    
    LEFT JOIN '/tmp/storage/random_num_gen.parquet' R ON R.game_id = S.game_id
    LEFT JOIN '/tmp/storage/reg_season_end.parquet' EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN '/tmp/storage/reg_season_end.parquet' EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
    
WHERE S.type = 'playin_r1'