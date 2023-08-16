SELECT 
    game_id,
    home_team,
    home_team_elo_rating,
    visiting_team,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances,
    CASE WHEN home_team_win_probability/10000 >= 0.5 
        THEN '-' || ROUND( home_team_win_probability/10000 / ( 1.0 - home_team_win_probability/10000 ) * 100 )::int
        ELSE '+' || ((( 1.0 - home_team_win_probability/10000 ) / (home_team_win_probability/10000::real ) * 100)::int)
    END AS american_odds
FROM "mdsbox"."main"."nfl_reg_season_simulator" S
    GROUP BY ALL