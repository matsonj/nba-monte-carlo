with cte_inner as (
    SELECT
        S.id as game_id,
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
        {{ var('include_actuals') }} AS include_actuals
    FROM {{ ref( 'nba_raw_schedule' ) }} S
        LEFT JOIN {{ ref( 'nba_raw_results' ) }} R ON R."date" = S."date"
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
    game_result AS game_result_v2
FROM cte_outer