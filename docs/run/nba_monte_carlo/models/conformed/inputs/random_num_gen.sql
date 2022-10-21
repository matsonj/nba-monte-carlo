

  create  table
    "main_main"."random_num_gen__dbt_tmp"
  as (
    

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM "main"."main_main"."scenario_gen" AS i
CROSS JOIN "main"."main_main"."schedules" AS S
  );

