SELECT
    game_id,
    vis_short as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_short as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_win_pct1,
    american_odds AS odds
FROM nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id