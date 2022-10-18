





SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating

FROM '/tmp/storage/raw_team_ratings/*.parquet'

GROUP BY ALL