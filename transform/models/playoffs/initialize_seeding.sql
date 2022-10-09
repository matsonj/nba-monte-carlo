WITH cte_teams AS (
    SELECT scenario_id,
        conf,
        winning_team,
        seed
    FROM {{ ref( 'reg_season_end' ) }}
    WHERE season_rank < 7
    UNION ALL 
    SELECT *
    FROM {{ ref('playin_r2_end' ) }}
)
SELECT T.*,
    R.elo_rating
FROM cte_teams T
    LEFT JOIN {{ ref('ratings' ) }} R ON T.winning_team = R.team