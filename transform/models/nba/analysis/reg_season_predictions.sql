with cte_team_scores AS (
    from {{ ref( 'nba_results_by_team') }}
    SELECT
        team,
        avg(score) as pts
    group by all
),
cte_interim_calcs AS (
SELECT 
    game_id,
    date,
    home_team,
    home_team_elo_rating,
    visiting_team,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances,
    {{ american_odds( 'home_team_win_probability/10000' ) }} AS american_odds,
    type,
    (H.pts + V.pts) / 2.0 AS avg_score,
    ROUND( CASE
        WHEN home_team_win_probability/10000 >= 0.50 THEN ROUND( -30.564 * home_team_win_probability/10000 + 14.763, 1 )
        ELSE ROUND( -30.564 * home_team_win_probability/100000 + 15.801, 1 )
    END * 2, 0 ) / 2.0 AS implied_line
FROM {{ ref( 'reg_season_simulator' ) }} S
LEFT JOIN cte_team_scores H ON H.team = S.home_team
LEFT JOIN cte_team_scores V ON V.team = S.visiting_team
GROUP BY ALL
),
cte_final AS (
SELECT
    *,
    ROUND(avg_score + (implied_line / 2.0),0) AS home_score,
    ROUND(avg_score - (implied_line / 2.0),0) AS visiting_score
FROM cte_interim_calcs
)
SELECT *,
    home_score || ' - ' || visiting_score AS predicted_score
FROM cte_final