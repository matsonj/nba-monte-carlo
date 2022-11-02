SELECT
    *,
    {{ var('latest_ratings') }} AS latest_ratings
FROM {{ "'/tmp/data_catalog/prep/elo_post.parquet'" }}
