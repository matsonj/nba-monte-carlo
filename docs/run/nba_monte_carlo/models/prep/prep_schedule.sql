
  create view "main"."prep_schedule__dbt_tmp" as (
    

SELECT *
FROM "main"."main"."raw_schedule"
  );
