
  create view "main_prep"."prep_nba_elo_latest__dbt_tmp" as (
    

SELECT *
FROM "main"."raw"."nba_elo_latest"
  );
