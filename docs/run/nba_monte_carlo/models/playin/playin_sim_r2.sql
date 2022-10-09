
  create view "main"."playin_sim_r2__dbt_tmp" as (
    SELECT 
    R.scenario_id,
    S.game_id,
    S.home_team[7:] AS home_team_id,
    S.visiting_team[8:] AS visiting_team_id,
    EV.remaining_team AS visiting_team,
    RV.elo_rating AS visiting_team_elo_rating,
    EH.remaining_team AS home_team,
    RH.elo_rating AS home_team_elo_rating,
    1-(1/(10^(-(RV.elo_rating - RH.elo_rating )::dec/400)+1)) as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN 1-(1/(10^(-(RV.elo_rating - RH.elo_rating )::dec/400)+1)) >= R.rand_result THEN EH.remaining_team
        ELSE EV.remaining_team
    END AS winning_team 
FROM "main"."main"."schedules" S
    LEFT JOIN "main"."main"."playin_random_num_gen" R ON R.game_id = S.game_id
    LEFT JOIN "main"."main"."playin_r1_end" EH ON R.scenario_id = EH.scenario_id AND EH.game_id = S.home_team[7:]
    LEFT JOIN "main"."main"."ratings" RH ON RH.team = EH.remaining_team
    LEFT JOIN "main"."main"."playin_r1_end" EV ON R.scenario_id = EV.scenario_id AND EV.game_id = S.visiting_team[8:]
    LEFT JOIN "main"."main"."ratings" RV ON RV.team = EV.remaining_team
WHERE S.type = 'playin_r2'
  );
