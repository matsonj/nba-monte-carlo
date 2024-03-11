MODEL (
  name nba.results_by_team,
  kind VIEW
);

FROM nba.results_log
SELECT 
    game_id,
    'home' as team_type,
    hmTm as team,
    home_team as team_long,
    home_team_score as score,
    CASE WHEN home_team = winning_team THEN 'WIN' ELSE 'LOSS' END AS game_results,
    home_team_score - visiting_team_score AS margin,
    type
UNION ALL
FROM nba.results_log
SELECT 
    game_id,
    'visitor' as team_type,
    VsTm as team,
    visiting_team as team_long,
    visiting_team_score as score,
    CASE WHEN visiting_team = winning_team THEN 'WIN' ELSE 'LOSS' END AS game_results,
    visiting_team_score - home_team_score AS margin,
    type;