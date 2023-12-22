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
            WHEN home_win_pct2 < 0.1 THEN -201.68 * home_win_pct2 + 44.182
            WHEN home_win_pct2 >= 0.1 AND home_win_pct2 <= 0.9 THEN -45.412 * home_win_pct2 + 23.938
            WHEN home_win_pct2 > 0.9 THEN -308.62 * home_win_pct2 + 266.42
        END, 1 ) AS implied_line_num1
FROM src_ncaaf_reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id
