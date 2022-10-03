{{
  config(
    materialized = "table"
) }}

SELECT S.visitorneutral AS team_long,
    R.team
FROM {{ source( 'nba' , 'raw_schedule' ) }} S
    LEFT JOIN {{ ref( 'ratings' ) }} R ON R.team_long = S.visitorneutral
GROUP BY ALL