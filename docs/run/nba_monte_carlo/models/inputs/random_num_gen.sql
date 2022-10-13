
  create view "main"."random_num_gen__dbt_tmp" as (
    

with __dbt__cte__scenario_gen as (


SELECT i.generate_series as scenario_id
FROM generate_series(1,100000) i
),  __dbt__cte__ratings as (


SELECT team,
    team_long,
    conf,
    elo_rating::int as elo_rating
FROM '/tmp/storage/raw_team_ratings/*.parquet' S
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
SELECT S.key::int AS game_id,
    S.type,
    s.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM '/tmp/storage/raw_schedule/*.parquet' S
WHERE S.type <> 'reg_season'
GROUP BY ALL
)SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM __dbt__cte__scenario_gen i
CROSS JOIN __dbt__cte__schedules S
  );
