{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team1 AS home_team, 
    score1 AS home_team_score,
    team2 AS visiting_team,
    score2 AS visiting_team_score,
    date
FROM {{ ref( 'prep_nba_elo_latest' ) }}
WHERE score1 IS NOT NULL