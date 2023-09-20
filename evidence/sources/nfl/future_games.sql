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
        WHEN home_win_pct1 >= 0.52 THEN ROUND( -27.117 * home_win_pct1 + 13.512, 1 )
        ELSE ROUND( -27.275 * home_win_pct1 + 14.759, 1 ) 
    END AS implied_line_num1
FROM nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id