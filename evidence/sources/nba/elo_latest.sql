SELECT *,
    elo_rating - original_rating as since_start
FROM nba_latest_elo