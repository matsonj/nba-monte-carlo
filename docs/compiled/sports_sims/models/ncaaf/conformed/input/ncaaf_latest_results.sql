with cte_inner as (
    SELECT
        S.id as game_id,
        S.week as week_number,
        S.HomeTm AS home_team, 
        CASE
            WHEN S.HomeTm = R.Winner THEN R.Winner_Pts
            ELSE R.Loser_Pts 
        END AS home_team_score,
        S.VisTm AS visiting_team,
        CASE
            WHEN S.VisTm = R.Winner THEN R.Winner_Pts
            ELSE R.Loser_Pts 
        END AS  visiting_team_score,
        R.Winner AS winning_team,
        R.Loser AS losing_team,
        True AS include_actuals,

    FROM "mdsbox"."main"."ncaaf_prep_schedule" S
        LEFT JOIN "mdsbox"."main"."ncaaf_prep_results" R ON R.Wk = S.week
            AND (S.VisTm = R.Winner OR S.VisTm = R.Loser)
    WHERE home_team_score IS NOT NULL 
    GROUP BY ALL
)
SELECT *,
    CASE
        WHEN visiting_team_score > home_team_score THEN 1
        ELSE 0
    END AS game_result
FROM cte_inner