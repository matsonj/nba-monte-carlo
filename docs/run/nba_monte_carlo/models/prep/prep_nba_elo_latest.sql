
  create view "main"."prep_nba_elo_latest__dbt_tmp" as (
    

SELECT *
FROM "main"."main"."raw_nba_elo_latest"
GROUP BY ALL
  );
