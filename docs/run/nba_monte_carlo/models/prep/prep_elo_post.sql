
  create view "main"."prep_elo_post__dbt_tmp" as (
    SELECT
    *,
    True AS latest_ratings
FROM '/tmp/data_catalog/prep/elo_post.parquet'
  );
