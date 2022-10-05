{{
  config(
    materialized = "view"
) }}

SELECT i.scenario_id,
    s.game_id,
    random() as rand_result
FROM {{ ref( 'scenario_gen' ) }} i
    CROSS JOIN {{ ref( 'schedules' ) }} S
WHERE S.type = 'playin'