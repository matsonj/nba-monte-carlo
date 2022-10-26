
  create view "main"."raw_team_ratings__dbt_tmp" as (
    

SELECT *
FROM "main"."psa"."team_ratings"
  );
