{{
    config(materialized='external')
}}

WITH cte_avg_elo AS (
   SELECT AVG(elo_rating) AS elo_rating
   FROM {{ source( 'nba_prep', 'elo_post' ) }}
)
SELECT 
   RL.*, 
   CASE WHEN visiting_team_elo_rating > home_team_elo_rating 
      THEN visiting_team ELSE home_team END AS favored_team,
   CASE WHEN visiting_team_elo_rating > elo_rating THEN 1 ELSE 0 END AS visiting_team_above_avg,
   CASE WHEN home_team_elo_rating > elo_rating THEN 1 ELSE 0 END AS home_team_above_avg
FROM  {{ source( 'nba_prep', 'results_log' ) }} RL
LEFT JOIN cte_avg_elo A ON 1=1

-- check to make sure UTA games where they are favored is correct.
-- will need to look at the materialized table and make sure its good.