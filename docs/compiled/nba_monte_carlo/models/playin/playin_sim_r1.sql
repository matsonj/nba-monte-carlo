SELECT 
    R.scenario_id,
    S.game_id,
    EV.conf AS conf,
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
    LEFT JOIN "main"."main"."reg_season_end" EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN "main"."main"."reg_season_end" EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
WHERE S.type = 'playin_r1'