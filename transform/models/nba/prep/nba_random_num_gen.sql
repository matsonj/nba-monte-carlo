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
CROSS JOIN {{ ref( 'nba_schedules' ) }} AS S
--LEFT JOIN {{ ref( 'nba_latest_results' )}} AS R ON R.game_id = S.game_id
--WHERE R.game_id IS NULL OR (R.game_id IS NOT NULL AND i.scenario_id = 1)