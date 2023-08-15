{{ 
    config(
        materialized='table'
) }}

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result,
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM {{ ref( 'nfl_scenario_gen' ) }} AS i
CROSS JOIN {{ ref( 'nfl_schedules' ) }} AS S
