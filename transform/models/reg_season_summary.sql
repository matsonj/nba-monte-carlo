{{
  config(
    materialized = "table"
) }}

SELECT scenario_id, 
    winning_team, 
    COUNT(1) as wins
FROM {{ ref( 'reg_season_simulator' ) }}
GROUP BY ALL