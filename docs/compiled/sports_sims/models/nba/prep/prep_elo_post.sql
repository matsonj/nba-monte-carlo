SELECT
    *,
    True AS latest_ratings
FROM  '/workspaces/nba-monte-carlo/data/data_catalog/prep/elo_post.parquet'