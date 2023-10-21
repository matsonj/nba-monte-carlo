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
        {{ var('include_actuals') }} AS include_actuals,

    FROM {{ ref( 'ncaaf_raw_schedule' ) }} S
        LEFT JOIN {{ ref( 'ncaaf_raw_results' ) }} R ON R.Wk = S.week
            AND (S.VisTm = R.Winner OR S.VisTm = R.Loser)
    WHERE home_team_score IS NOT NULL 
    GROUP BY ALL
),
cte_outer AS (
    SELECT *,
        CASE
            WHEN visiting_team_score > home_team_score THEN 1
            WHEN visiting_team_score = home_team_score THEN 0.5
            ELSE 0
        END AS game_result,
        ABS( visiting_team_score - home_team_score ) as margin
    FROM cte_inner
)
SELECT *,
    CASE
        WHEN margin < 4 AND game_result = 1 THEN 0.585
        WHEN margin < 4 AND game_result = 0 THEN 0.415
        WHEN margin < 6 AND game_result = 1 THEN 0.666
        WHEN margin < 6 AND game_result = 0 THEN 0.334
        WHEN margin = 6 AND game_result = 1 THEN 0.707
        WHEN margin = 6 AND game_result = 0 THEN 0.293
        WHEN margin = 7 AND game_result = 1 THEN 0.73
        WHEN margin = 7 AND game_result = 0 THEN 0.27
        WHEN margin = 8 AND game_result = 1 THEN 0.75
        WHEN margin = 8 AND game_result = 0 THEN 0.25
        WHEN margin > 8 AND margin < 17 AND game_result = 1 THEN 0.85
        WHEN margin > 8 AND margin < 17 AND game_result = 0 THEN 0.15
        ELSE game_result
    END AS game_result_v2
FROM cte_outer