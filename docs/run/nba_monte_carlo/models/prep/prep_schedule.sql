
  create view "main_prep"."prep_schedule__dbt_tmp" as (
    

SELECT *
FROM "main"."raw"."nba_schedule_2023"
  );
