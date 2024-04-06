MODEL (
  name nba.random_num_gen,
  kind FULL
);

@DEF(scenarios, 10000);

WITH cte_scenario_gen AS (
    SELECT I.generate_series AS scenario_id
    FROM generate_series(1, @scenarios ) AS I
)
SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result,
    0 AS sim_start_game_id
FROM cte_scenario_gen AS i
CROSS JOIN nba.schedules AS S;