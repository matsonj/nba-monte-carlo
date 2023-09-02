SELECT 
    game_id,
    home_team,
    Home.team_short AS home_short,
    home_team_elo_rating,
    visiting_team,
    Visitor.team_short AS vis_short,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances,
    {{ american_odds( 'home_team_win_probability/10000' ) }} AS american_odds
FROM {{ ref( 'nfl_reg_season_simulator' ) }} S
LEFT JOIN {{ ref( 'nfl_ratings' ) }} Home ON Home.team = S.home_team
LEFT JOIN {{ ref( 'nfl_ratings' ) }} Visitor ON Visitor.team = S.visiting_team
GROUP BY ALL



