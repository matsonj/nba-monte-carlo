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
        WHEN home_win_pct1 >= 0.50 THEN ROUND( -53.839 * home_win_pct1^2 + 44.494 * home_win_pct1 - 10.287, 1 )
        ELSE ROUND( 54.501 * home_win_pct1^2 -64.296 * home_win_pct1 + 20.085, 1 )
    END AS implied_line_num1
FROM src_nfl_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id
