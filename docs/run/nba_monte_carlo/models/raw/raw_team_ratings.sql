
  create view "main"."raw_team_ratings__dbt_tmp" as (
    

SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
  );
