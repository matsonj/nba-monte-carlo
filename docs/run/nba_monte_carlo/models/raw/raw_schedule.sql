
  create view "main"."raw_schedule__dbt_tmp" as (
    

SELECT *
FROM "main"."psa"."nba_schedule_2023"
  );
