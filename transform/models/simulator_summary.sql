{{
  config(
    materialized = "table"
) }}

SELECT scenario_id, 
    winning_team, 
    COUNT(1) as wins
FROM {{ ref( 'simulator' ) }}
GROUP BY ALL