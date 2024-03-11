MODEL (
  name nba.reg_season_simulator,
  kind FULL
);

JINJA_QUERY_BEGIN;
SELECT 
    R.scenario_id,
    S.*,
    {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating', 100 ) }} as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN LR.include_actuals = true THEN LR.winning_team_short
        WHEN {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating', 100 ) }}  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team,
    COALESCE(LR.include_actuals, false) AS include_actuals,
    LR.home_team_score AS actual_home_team_score,
    LR.visiting_team_score AS actual_visiting_team_score,
    LR.margin AS actual_margin
FROM nba.schedules S
LEFT JOIN nba.random_num_gen R ON R.game_id = S.game_id
LEFT JOIN nba.latest_results LR ON LR.game_id = S.game_id
WHERE S.type IN ('reg_season','tournament','knockout');
JINJA_END;