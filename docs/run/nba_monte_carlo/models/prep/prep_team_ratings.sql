
  create view "main_prep"."prep_team_ratings__dbt_tmp" as (
    

SELECT *
FROM "main"."raw"."team_ratings"
  );
