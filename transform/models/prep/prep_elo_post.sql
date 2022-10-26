{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    *,
    {{ var('latest_ratings') }} AS latest_ratings
FROM {{ "'/tmp/storage/elo_post.parquet'" if target.name == 'parquet' 
    else source('nba', 'elo_post' ) }}