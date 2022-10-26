
  create view "main"."prep_elo_post__dbt_tmp" as (
    

SELECT
    *,
    True AS latest_ratings
FROM "main"."psa"."elo_post"
  );
