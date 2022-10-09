
  create view "main"."scenario_gen__dbt_tmp" as (
    

SELECT i.generate_series as scenario_id
FROM generate_series(1,10000) i
  );
