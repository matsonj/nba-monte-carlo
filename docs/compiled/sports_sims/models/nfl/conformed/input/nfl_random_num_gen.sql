

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result,
    0 AS sim_start_game_id
FROM "mdsbox"."main"."nfl_scenario_gen" AS i
CROSS JOIN "mdsbox"."main"."nfl_schedules" AS S