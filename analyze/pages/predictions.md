# Predictions

```past_games
SELECT *
FROM reg_season_predictions
WHERE include_actuals = true
ORDER BY game_id
```

```future_games
SELECT
    game_id,
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_team_win_pct2
FROM reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team
ORDER BY game_id
```

<DataTable
    data={future_games}
    title='Predictions'
    rows=25
/>