SELECT
    *,
    elo_rating - original_rating AS since_start_num1
FROM nfl_latest_elo