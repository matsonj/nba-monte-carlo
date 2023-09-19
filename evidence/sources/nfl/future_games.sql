SELECT
    game_id,
    vis_short as visitor,
    visiting_team,
    visiting_team_elo_rating AS visitor_ELO,
    home_short as home, 
    home_team,
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_win_pct2,
    american_odds AS odds,
    ROUND( -30.17 * home_win_pct2 + 15.693, 1 ) AS implied_line_num1
FROM nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id