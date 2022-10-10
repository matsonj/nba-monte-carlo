{{
  config(
    materialized = "table"
) }}

SELECT team,
    win_total
FROM {{ source( 'nba' , 'raw_team_ratings' ) }} S
GROUP BY ALL