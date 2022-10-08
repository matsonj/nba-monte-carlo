SELECT scenario_id,
    conf,
    winning_team,
    seed
FROM {{ ref( 'reg_season_end' ) }}
WHERE season_rank < 7
UNION ALL 
SELECT *
FROM {{ ref('playin_r2_end' ) }}