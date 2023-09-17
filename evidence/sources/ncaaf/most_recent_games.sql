SELECT
    RL.week_number as week,
    RL.visiting_team,
    '@' as " ",
    RL.home_team,
    RL.home_team_score || ' - ' || RL.visiting_team_score as score,
    RL.winning_team,
    ABS(AR.elo_change) AS elo_change_num1
FROM ncaaf_latest_results RL
LEFT JOIN ncaaf_elo_rollforward AR ON
    AR.game_id = RL.game_id
ORDER BY RL.week_number