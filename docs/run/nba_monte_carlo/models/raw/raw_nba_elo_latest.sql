
  create view "main"."raw_nba_elo_latest__dbt_tmp" as (
    

SELECT *
FROM "main"."psa"."nba_elo_latest"
  );
