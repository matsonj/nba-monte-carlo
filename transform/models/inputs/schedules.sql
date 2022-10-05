{{
  config(
    materialized = "table"
) }}

SELECT S.key::int AS game_id,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM {{ source( 'nba' , 'raw_schedule' ) }} S
    LEFT JOIN {{ ref( 'ratings' ) }} V ON V.team_long = S.visitorneutral
    LEFT JOIN {{ ref( 'ratings' ) }} H ON H.team_long = S.homeneutral 
GROUP BY ALL