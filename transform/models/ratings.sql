{{
  config(
    materialized = "table"
) }}

SELECT team,
    team_long,
    conf,
    win_total,
    elo_rating::int as elo_rating
FROM {{ source( 'nba' , 'raw_team_ratings' ) }} S
GROUP BY ALL