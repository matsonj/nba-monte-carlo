WITH cte_team AS 
    (SELECT winning_team AS team FROM ${past_games} GROUP BY ALL)
SELECT
    T.Team,
    COUNT(*) as total_games_played, 
    SUM(PG.accurate_guess) AS correct_predictions,
    correct_predictions/total_games_played::real AS accuracy_pct1
FROM ${past_games} PG
    LEFT JOIN cte_team T ON T.team = PG.visiting_team OR T.Team = PG.home_team
GROUP BY ALL
ORDER BY accuracy_pct1 DESC