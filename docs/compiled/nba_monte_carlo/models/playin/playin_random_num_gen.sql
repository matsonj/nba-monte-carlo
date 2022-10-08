

SELECT i.scenario_id,
    s.game_id,
    random() as rand_result
FROM "main"."main"."scenario_gen" i
    CROSS JOIN "main"."main"."schedules" S
WHERE S.type = 'playin_r1'