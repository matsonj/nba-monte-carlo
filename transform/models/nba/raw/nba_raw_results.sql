WITH cte_base AS (
    SELECT * FROM {{ source( 'nba_dlt','games' ) }}
)

SELECT
    date::date as "date",
    NULL as "Start (ET)",
    away.team_long as "VisTm",
    away_points::int as visiting_team_score,
    home.team_long as "HomeTm",
    home_points::int as home_team_score,
    NULL as "Attend.",
    NULL as Arena,
    NULL as Notes,
    CASE WHEN visiting_team_score > home_team_score 
        THEN VisTm
        ELSE HomeTm
    END AS Winner,
    CASE WHEN visiting_team_score > home_team_score 
        THEN HomeTm
        ELSE VisTm
    END AS Loser,
    CASE WHEN visiting_team_score > home_team_score 
        THEN visiting_team_score
        ELSE home_team_score
    END AS Winner_Pts,
    CASE WHEN visiting_team_score > home_team_score 
        THEN home_team_score
        ELSE visiting_team_score
    END AS Loser_Pts
FROM cte_base a
LEFT JOIN {{ ref( 'nba_raw_team_ratings' ) }} home
    ON home.alt_key = a.home_team_abbreviation
LEFT JOIN {{ ref( 'nba_raw_team_ratings' ) }} away
    ON away.alt_key = a.away_team_abbreviation