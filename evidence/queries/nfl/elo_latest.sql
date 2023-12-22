SELECT
    *,
    elo_rating - original_rating AS since_start_num1
FROM src_nfl_latest_elo