SELECT
    S.game_id,
    S.Week_number,
    S.home_team, 
    CASE
        WHEN S.home_team = R.Winner THEN R.Winner_Pts
        ELSE R.Loser_Pts 
    END AS home_team_score,
    S.visiting_team AS visiting_team,
    CASE
        WHEN S.visiting_team = R.Winner THEN R.Winner_Pts
        ELSE R.Loser_Pts 
    END AS  visiting_team_score,
    R.Winner AS winning_team,
    R.Loser AS losing_team,
    True AS include_actuals
FROM "mdsbox"."main"."ncaaf_schedules" S
    LEFT JOIN "mdsbox"."main"."ncaaf_prep_results" R ON R.Wk = S.Week_number
        AND (S.visiting_team = R.Winner OR S.visiting_team = R.Loser)
WHERE home_team_score IS NOT NULL 
GROUP BY ALL