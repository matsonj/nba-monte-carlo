{{
  config(
    materialized = "ephemeral"
) }}

SELECT
    i.scenario_id,
    S.game_id,
    random() AS rand_result
FROM {{ ref( 'scenario_gen' ) }} i
CROSS JOIN {{ ref( 'schedules' ) }} S