MODEL (
  name nba.latest_results,
  kind FULL,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column game_date
  )
);

with cte_inner as (
    SELECT
        S.id as game_id,
        S."date" as game_date,
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
        true AS include_actuals
    FROM nba.prep_schedule S
        LEFT JOIN nba.prep_results R ON R."date" = S."date"
            AND (S.VisTm = R.Winner OR S.VisTm = R.Loser)
    WHERE home_team_score IS NOT NULL 
    GROUP BY ALL
),
cte_outer AS (
    SELECT I.*,
        CASE
            WHEN visiting_team_score > home_team_score THEN 1
            WHEN visiting_team_score = home_team_score THEN 0.5
            ELSE 0
        END AS game_result,
        ABS( visiting_team_score - home_team_score ) as margin,
        W.team AS winning_team_short,
        L.team AS losing_team_short
    FROM cte_inner I
    LEFT JOIN nba.teams W ON W.team_long = I.winning_team
    LEFT JOIN nba.teams L ON L.team_long = I.losing_team
)
SELECT *,
    CASE
        WHEN margin < 4 AND game_result = 1 THEN 0.581
        WHEN margin < 4 AND game_result = 0 THEN 0.419
        WHEN margin < 6 AND game_result = 1 THEN 0.647
        WHEN margin < 6 AND game_result = 0 THEN 0.353
        WHEN margin < 9 AND game_result = 1 THEN 0.745
        WHEN margin < 9 AND game_result = 0 THEN 0.255
        WHEN margin < 12 AND game_result = 1 THEN 0.876
        WHEN margin < 12 AND game_result = 0 THEN 0.124
        ELSE game_result
    END AS game_result_v2
FROM cte_outer
WHERE
  game_date BETWEEN @start_ds AND @end_ds;