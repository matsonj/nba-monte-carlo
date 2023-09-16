SELECT
    game_id,
    vis_short as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_short as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_win_pct2, 
    american_odds AS odds,
    ROUND( 
        CASE
            WHEN home_win_pct2 < 0.1 THEN -212.28 * home_win_pct2 + 41.475
            WHEN home_win_pct2 >= 0.1 AND home_win_pct2 <= 0.9 THEN -41.437 * home_win_pct2 + 21.862
            WHEN home_win_pct2 > 0.9 THEN -201.86 * home_win_pct2 + 167.42
        END, 1 ) AS implied_line_num1
FROM ncaaf_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id