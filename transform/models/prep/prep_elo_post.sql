SELECT
    *,
    {{ var('latest_ratings') }} AS latest_ratings
FROM {{ "'/workspaces/nba-monte-carlo/data/data_catalog/prep/elo_post.parquet'" }}
