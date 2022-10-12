{{
  config(
    materialized = "ephemeral"
) }}

SELECT team,
    team_long,
    conf,
    elo_rating::int as elo_rating
FROM '/tmp/storage/raw_team_ratings/*.parquet' S
GROUP BY ALL