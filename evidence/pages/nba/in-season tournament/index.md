```future_games
SELECT
    game_id,
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_team_win_pct1,
    american_odds
FROM reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team and type = 'tournament'
ORDER BY game_id
```

```past_games
SELECT *,
    CASE
        WHEN (home_team_win_probability > 5000.0 AND winning_team = home_team)
            OR (home_team_win_probability < 5000.0 AND winning_team = visiting_team)
            THEN 1 ELSE 0 END AS 'accurate_guess'
FROM reg_season_predictions
WHERE include_actuals = true and type = 'tournament'
ORDER BY game_id
```

```tournament_results
FROM tournament_end
SELECT
    winning_team,
    tournament_group,
    sum(made_tournament) / 10000.0 as won_group,
    sum(made_wildcard) / 30000.0 as made_wildcard,
    sum(made_tournament) / 10000.0 + sum(made_wildcard) / 30000.0 as made_tournament,
    avg(wins) as wins,
    avg(losses) as losses
GROUP BY ALL
ORDER BY tournament_group, made_tournament DESC
```

# NBA In-season Tournament

## Standings

## Recent Games

## Predicted Matchups
