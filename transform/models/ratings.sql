{{
  config(
    materialized = "table"
) }}

SELECT team,
    team_long,
    win_total,
    elo_rating::int as elo_rating
FROM {{ source( 'nba' , 'raw_team_ratings' ) }} S
GROUP BY ALL