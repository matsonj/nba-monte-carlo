with __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
)SELECT
    (_smart_source_lineno - 1)::int AS game_id,
    team1 AS home_team, 
    score1 AS home_team_score,
    team2 AS visiting_team,
    score2 AS visiting_team_score,
    date,
    CASE 
        WHEN score1 > score2 THEN team1
        ELSE team2
    END AS winning_team,
    CASE 
        WHEN score1 > score2 THEN team2
        ELSE team1
    END AS losing_team,
    True AS include_actuals
FROM __dbt__cte__prep_nba_elo_latest
WHERE score1 IS NOT NULL
GROUP BY ALL