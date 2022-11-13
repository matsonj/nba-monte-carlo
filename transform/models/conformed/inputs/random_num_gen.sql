{{ 
    config(
        materialized='table'
) }}

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM {{ ref( 'scenario_gen' ) }} AS i
CROSS JOIN {{ ref( 'schedules' ) }} AS S
