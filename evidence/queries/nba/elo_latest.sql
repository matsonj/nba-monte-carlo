SELECT *,
    elo_rating - original_rating as since_start
FROM src_nba_latest_elo