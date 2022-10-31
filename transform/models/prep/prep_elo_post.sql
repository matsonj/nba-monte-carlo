{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    *,
    {{ var('latest_ratings') }} AS latest_ratings
FROM {{ "'s3://datalake/prep/elo_post.parquet'" }}
