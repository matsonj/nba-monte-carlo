MODEL (
  name nba.playin_sim_r1,
  kind VIEW
);

JINJA_QUERY_BEGIN;
SELECT
    R.scenario_id,
    S.game_id,
    EV.conf AS conf,
    EV.winning_team AS visiting_team,
    EV.elo_rating AS visiting_team_elo_rating,
    EH.winning_team AS home_team,
    EH.elo_rating AS home_team_elo_rating,
    {{ elo_calc( 'EH.elo_rating', 'EV.elo_rating', 100 ) }} AS home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN {{ elo_calc( 'EH.elo_rating', 'EV.elo_rating', 100 ) }} >= R.rand_result THEN EH.winning_team
        ELSE EV.winning_team
    END AS winning_team 
FROM nba.schedules S
    LEFT JOIN nba.random_num_gen R ON R.game_id = S.game_id
    LEFT JOIN nba.reg_season_end EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN nba.reg_season_end EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
WHERE S.type = 'playin_r1';
JINJA_END;