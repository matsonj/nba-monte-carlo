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

    FROM {{ ref( 'ncaaf_prep_schedule' ) }} S
        LEFT JOIN {{ ref( 'ncaaf_prep_results' ) }} R ON R.Wk = S.week
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
        WHEN margin < 4 THEN 0.5
        WHEN margin < 6 AND game_result = 1 THEN 0.58
        WHEN margin < 6 AND game_result = 0 THEN 0.42
        WHEN margin = 6 AND game_result = 1 THEN 0.66
        WHEN margin = 6 AND game_result = 0 THEN 0.34
        WHEN margin = 7 AND game_result = 1 THEN 0.74
        WHEN margin = 7 AND game_result = 0 THEN 0.26
        WHEN margin = 8 AND game_result = 1 THEN 0.82
        WHEN margin = 8 AND game_result = 0 THEN 0.18
        WHEN margin > 8 AND margin < 17 AND game_result = 1 THEN 0.9
        WHEN margin > 8 AND margin < 17 AND game_result = 0 THEN 0.1
        ELSE game_result
    END AS game_result_v2
FROM cte_outer