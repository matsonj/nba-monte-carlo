{{
  config(
    materialized = "table"
) }}

SELECT S.visitorneutral AS team_name
FROM {{ source( 'nba' , 'schedule' ) }} S
GROUP BY ALL