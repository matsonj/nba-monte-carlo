# Predictions

```past_games
SELECT *,
    CASE
        WHEN (home_team_win_probability > 5000.0 AND winning_team = home_team)
            OR (home_team_win_probability < 5000.0 AND winning_team = visiting_team)
            THEN 1 ELSE 0 END AS 'accurate_guess'
FROM reg_season_predictions
WHERE include_actuals = true
ORDER BY game_id
```

```past_games_summary
SELECT
    COUNT(*) as total_games_played, 
    SUM(accurate_guess) AS correct_predictions,
    correct_predictions/total_games_played::real AS accuracy_pct1
FROM ${past_games}
```

```past_games_summary_by_team
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
ORDER BY accuracy_pct DESC
```

```future_games
SELECT
    game_id,
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_team_win_pct1
FROM reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id
```
## Past Performance

<BigValue 
    data={past_games_summary} 
    value='total_games_played' 
/> 

<BigValue 
    data={past_games_summary} 
    value='correct_predictions' 
/> 

<BigValue 
    data={past_games_summary} 
    value='accuracy_pct1' 
/> 

<DataTable
    data={past_games_summary_by_team}
    title='Prediction Accuracy by Team'
    rows=30
/>

## Future Predictions

<DataTable
    data={future_games}
    title='Predictions'
    rows=25
/>