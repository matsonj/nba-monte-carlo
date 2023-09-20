SELECT
    game_id,
    vis_short as visitor,
    visiting_team,
    visiting_team_elo_rating AS visitor_ELO,
    home_short as home, 
    home_team,
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_win_pct1,
    american_odds AS odds,
    CASE
        WHEN home_win_pct1 >= 0.52 THEN ROUND( -55.048 * home_win_pct1^2 + 47.837 * home_win_pct1 - 11.56, 1 )
        ELSE ROUND( 55.564 * home_win_pct1^2 -67.229 * home_win_pct1 + 21.501, 1 )
    END AS implied_line_num1
FROM nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id