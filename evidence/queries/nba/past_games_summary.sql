SELECT
    COUNT(*) as total_games_played, 
    SUM(accurate_guess) AS correct_predictions,
    correct_predictions/total_games_played::real AS accuracy_pct1
FROM ${past_games}