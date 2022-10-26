
  create view "main"."prep_team_ratings__dbt_tmp" as (
    

SELECT *
FROM "main"."main"."raw_team_ratings"
  );
