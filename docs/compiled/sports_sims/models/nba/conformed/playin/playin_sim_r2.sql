SELECT 
    R.scenario_id,
    S.game_id,
    S.home_team[7:] AS home_team_id,
    S.visiting_team[8:] AS visiting_team_id,
    EV.conf AS conf,
    EV.remaining_team AS visiting_team,
    EV.winning_team_elo_rating AS visiting_team_elo_rating,
    EH.remaining_team AS home_team,
    EH.losing_team_elo_rating AS home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( EV.winning_team_elo_rating - EH.losing_team_elo_rating - 70)::real/400)+1))) * 10000 as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN ( 1 - (1 / (10 ^ (-( EV.winning_team_elo_rating - EH.losing_team_elo_rating - 70)::real/400)+1))) * 10000 >= R.rand_result THEN EH.remaining_team
        ELSE EV.remaining_team
    END AS winning_team 
FROM "mdsbox"."main"."schedules" S
    LEFT JOIN "mdsbox"."main"."random_num_gen" R ON R.game_id = S.game_id
    LEFT JOIN "mdsbox"."main"."playin_sim_r1_end" EH ON R.scenario_id = EH.scenario_id AND EH.game_id = S.home_team[7:]
    LEFT JOIN "mdsbox"."main"."playin_sim_r1_end" EV ON R.scenario_id = EV.scenario_id AND EV.game_id = S.visiting_team[8:]
WHERE S.type = 'playin_r2'