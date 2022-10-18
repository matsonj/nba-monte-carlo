

  create  table
    "main"."random_num_gen__dbt_tmp"
  as (
    





SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM "main"."main"."scenario_gen" AS i
CROSS JOIN "main"."main"."schedules" AS S
  );

