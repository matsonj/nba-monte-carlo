SELECT
    game_id,
    date,
    CASE WHEN type = 'tournament' THEN '🏆' 
        WHEN type = 'knockout' THEN '🥊'
        ELSE '' END 
    AS "T",
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_elo_rating - visiting_team_elo_rating AS elo_diff,
    elo_diff + 100 AS elo_diff_hfa,
    home_team_win_probability/10000 AS home_win_pct1,
    american_odds,
    implied_line AS implied_line_num1,
    predicted_score,
    type,
    '/nba/predictions/' || (game_id::int) as game_link
FROM src_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id