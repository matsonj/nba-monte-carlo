{{ 
    config(
        materialized='table'
) }}

WITH cte_scenario_gen AS (
    SELECT I.generate_series AS scenario_id
    FROM generate_series(1, {{ var( 'scenarios' ) }} ) AS I
)
SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result,
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM cte_scenario_gen AS i
CROSS JOIN {{ ref( 'ncaaf_schedules' ) }} AS S
