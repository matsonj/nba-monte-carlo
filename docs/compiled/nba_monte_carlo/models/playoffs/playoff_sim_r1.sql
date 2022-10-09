

WITH cte_step_1 AS (
    SELECT 
        R.scenario_id,
        S.game_id,
        s.series_id,
        S.visiting_team,
        S.home_team,
        EV.winning_team AS visiting_team,
        EV.elo_rating AS visiting_team_elo_rating,
        EH.winning_team AS home_team,
        EH.elo_rating AS home_team_elo_rating,
        1-(1/(10^(-(EV.elo_rating - EH.elo_rating )::dec/400)+1)) as home_team_win_probability,
        R.rand_result,
        CASE 
            WHEN 1-(1/(10^(-(EV.elo_rating - EH.elo_rating )::dec/400)+1)) >= R.rand_result THEN EH.winning_team
            ELSE EV.winning_team
        END AS winning_team 
    FROM "main"."main"."schedules" S
        LEFT JOIN "main"."main"."random_num_gen" R ON R.game_id = S.game_id
        LEFT JOIN "main"."main"."initialize_seeding" EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
        LEFT JOIN "main"."main"."initialize_seeding" EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
    WHERE S.type = 'playoffs_r1' ),
cte_step_2 AS (
    SELECT step1.*,
        ROW_NUMBER() OVER (PARTITION BY scenario_id, series_id, winning_team  ORDER BY scenario_id, series_id, game_id ) AS series_result
    FROM cte_step_1 step1
),
cte_final_game AS (
    SELECT scenario_id,
        series_id,
        game_id
    FROM cte_step_2
    WHERE series_result = 4
)
SELECT step2.* 
FROM cte_step_2 step2
    INNER JOIN cte_final_game F ON F.scenario_id = step2.scenario_id 
        AND f.series_id = step2.series_id AND step2.game_id <= f.game_id
ORDER BY step2.scenario_id, 
    step2.series_id, 
    step2.game_id