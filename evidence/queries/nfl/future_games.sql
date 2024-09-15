SELECT
    game_id,
    week_number,
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_elo_rating - visiting_team_elo_rating AS elo_diff,
    elo_diff + 52 AS elo_diff_hfa,
    home_team_win_probability/10000 AS home_win_pct1,
    american_odds,
    ROUND((elo_diff_hfa/-25.0)*2,0)/2 AS implied_line,
    type,
 --   '/nfl/predictions/' || (game_id::int) as game_link
FROM src_nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id