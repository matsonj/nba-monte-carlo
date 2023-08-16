SELECT 
    R.scenario_id,
    S.*,
    -- removing the 70 point adjustment for home team advantage for now
   ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating - 0)::real/400)+1))) * 10000 as home_team_win_probability,
    R.rand_result,
    CASE 
        -- WHEN LR.include_actuals = true THEN LR.winning_team
        WHEN -- removing the 70 point adjustment for home team advantage for now
   ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating - 0)::real/400)+1))) * 10000  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team,
    --COALESCE(LR.include_actuals, false) AS include_actuals
    false as include_actuals
FROM "mdsbox"."main"."nfl_schedules" S
LEFT JOIN "mdsbox"."main"."nfl_random_num_gen" R ON R.game_id = S.game_id
-- LEFT JOIN 'nfl_latest_results'  LR ON LR.game_id = S.game_id
WHERE S.type = 'reg_season'