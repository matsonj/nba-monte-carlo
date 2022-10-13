

  create  table
    "main"."playoff_sim_r1_end__dbt_tmp"
  as (
    

with __dbt__cte__xf_series_to_seed as (


SELECT series_id,
    seed
FROM '/tmp/storage/raw_xf_series_to_seed/*.parquet'
)-- depends-on: "main"."main"."playoff_sim_r1"

SELECT
    E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed
FROM '/tmp/storage/playoff_sim_r1.parquet' E
LEFT JOIN __dbt__cte__xf_series_to_seed XF ON XF.series_id = E.series_id
WHERE E.series_result = 4
  );

