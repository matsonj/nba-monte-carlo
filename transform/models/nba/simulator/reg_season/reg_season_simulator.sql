SELECT 
    R.scenario_id,
    S.*,
    {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating', var('nba_elo_offset') ) }} as home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN LR.include_actuals = true THEN LR.winning_team_short
        WHEN {{ elo_calc( 'S.home_team_elo_rating', 'S.visiting_team_elo_rating', var('nba_elo_offset') ) }}  >= R.rand_result THEN S.home_team
        ELSE S.visiting_team
    END AS winning_team,
    COALESCE(LR.include_actuals, false) AS include_actuals
FROM {{ ref( 'nba_schedules' ) }} S
LEFT JOIN {{ ref( 'nba_random_num_gen' ) }} R ON R.game_id = S.game_id
LEFT JOIN {{ ref( 'nba_latest_results' ) }} LR ON LR.game_id = S.game_id
WHERE S.type IN ('reg_season','tournament')
