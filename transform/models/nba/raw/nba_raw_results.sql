WITH cte_base AS (
    SELECT * FROM {{ source( 'nba_dlt','games' ) }}
),
cte_seed as (
    SELECT * FROM {{ source( 'nba','nba_results' ) }}
)

SELECT
    coalesce(a.date,strptime(b."Date",'%a %b %-d %Y'))::date as "date",
    b."Start (ET)" as "Start (ET)",
    coalesce(away.team_long,b."Visitor/Neutral") as "VisTm",
    coalesce(a.away_points,b.PTS)::int as visiting_team_score,
    coalesce(home.team_long,b."Home/Neutral") as "HomeTm",
    coalesce(a.home_points,b.PTS_1)::int as home_team_score,
    b."Attend." as "Attend.",
    b.Arena as Arena,
    b.Notes as Notes,
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
FULL OUTER JOIN cte_seed b on  strptime(b."Date",'%a %b %-d %Y')::date = a.date
    AND b."Home/Neutral" = home.team_long