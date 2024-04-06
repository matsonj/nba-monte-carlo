MODEL (
  name nba.prep_results,
  kind VIEW 
);

WITH cte_base AS (
    SELECT * FROM nba.raw_results
)
SELECT
    strptime("Date",'%a %b %-d %Y')::date as "date",
    "Start (ET)" as "Start (ET)",
    "Visitor/Neutral" as "VisTm",
    PTS::int as visiting_team_score,
    "Home/Neutral" as "HomeTm",
    "PTS.1"::int as home_team_score,
    "Attend." as "Attend.",
    Arena as Arena,
    Notes as Notes,
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
FROM cte_base;
