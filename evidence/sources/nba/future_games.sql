SELECT
    game_id,
    CASE WHEN type = 'tournament' THEN '🏆' ELSE '' END AS "T",
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_win_pct1,
    american_odds,
    CASE
        WHEN home_win_pct1 >= 0.50 THEN ROUND( -30.564 * home_win_pct1 + 14.763, 1 )
        ELSE ROUND( -30.564 * home_win_pct1 + 15.801, 1 )
    END AS implied_line_num1
FROM reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id