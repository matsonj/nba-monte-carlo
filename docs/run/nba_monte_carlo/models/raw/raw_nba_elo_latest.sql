
  create view "main"."raw_nba_elo_latest__dbt_tmp" as (
    

SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
  );
