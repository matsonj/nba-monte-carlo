
  create view "main"."scenario_gen__dbt_tmp" as (
    

SELECT I.generate_series AS scenario_id
FROM generate_series(1, 500 ) AS I
  );
