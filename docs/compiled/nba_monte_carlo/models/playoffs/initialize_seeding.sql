SELECT scenario_id,
    conf,
    winning_team,
    seed
FROM "main"."main"."reg_season_end"
WHERE season_rank < 7
UNION ALL 
SELECT *
FROM "main"."main"."playin_r2_end"