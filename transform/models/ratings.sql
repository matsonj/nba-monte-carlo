{{
  config(
    materialized = "table"
) }}

SELECT team,
    team_long,
    win_total,
    elo_rating
FROM {{ source( 'nba' , 'team_ratings' ) }} S
GROUP BY ALL