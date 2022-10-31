
  create view "main"."raw_schedule__dbt_tmp" as (
    

SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
  );
