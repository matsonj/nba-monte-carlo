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
        {{ var('include_actuals') }} AS include_actuals
    FROM {{ ref( 'nba_raw_schedule' ) }} S
        LEFT JOIN {{ ref( 'nba_raw_results' ) }} R ON R."date" = S."date"
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
    LEFT JOIN {{ ref( 'nba_teams' ) }} W ON W.team_long = I.winning_team
    LEFT JOIN {{ ref( 'nba_teams' ) }} L ON L.team_long = I.losing_team
)
SELECT *,
    game_result AS game_result_v2
FROM cte_outer