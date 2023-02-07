SELECT 
    game_id,
    home_team,
    home_team_elo_rating,
    visiting_team,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances
FROM "main"."main"."reg_season_simulator" S
    GROUP BY ALL