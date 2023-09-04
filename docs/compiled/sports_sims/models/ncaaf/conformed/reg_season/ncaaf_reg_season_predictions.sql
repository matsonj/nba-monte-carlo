SELECT 
    game_id,
    home_team,
    Home.team AS home_short,
    home_team_elo_rating,
    visiting_team,
    Visitor.team AS vis_short,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances,
    CASE WHEN home_team_win_probability/10000 >= 0.5 
        THEN '-' || ROUND( home_team_win_probability/10000 / ( 1.0 - home_team_win_probability/10000 ) * 100 )::int
        ELSE '+' || ((( 1.0 - home_team_win_probability/10000 ) / (home_team_win_probability/10000::real ) * 100)::int)
    END AS american_odds
FROM "mdsbox"."main"."ncaaf_reg_season_simulator" S
LEFT JOIN "mdsbox"."main"."ncaaf_ratings" Home ON Home.team = S.home_team
LEFT JOIN "mdsbox"."main"."ncaaf_ratings" Visitor ON Visitor.team = S.visiting_team
GROUP BY ALL