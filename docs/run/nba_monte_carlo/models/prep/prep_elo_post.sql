
  create view "main_prep"."prep_elo_post__dbt_tmp" as (
    

SELECT
    *,
    True AS latest_ratings
FROM raw.elo_post
  );
