{{
    config(
        materialized = "view"
) }}

-- annoyingly, both playin games perform slightly differently (one game the winner advances to playoffs,
-- the other game the losing team is eliminated.) as a result, we have write specific code for those
-- game ids.
WITH cte_playin_details AS (
    SELECT S.scenario_id,
        S.game_id,
        S.winning_team,
        R.conf,
        CASE 
            WHEN S.winning_team = S.home_team THEN S.visiting_team
            ELSE S.home_team
        END AS losing_team,
        CASE 
            WHEN S.game_id IN (1231,1234) THEN 'winner advance'
            WHEN S.game_id IN (1232,1235) THEN 'loser eliminated'
        END AS result 
  FROM {{ ref( 'playin_sim_r1' ) }} S
        LEFT JOIN {{ ref( 'ratings' ) }} R ON R.team = S.winning_team
)
SELECT *,
        CASE
            WHEN game_id IN (1231,1234) THEN losing_team
            WHEN game_id IN (1232,1235) THEN winning_team
        END AS remaining_team 
FROM cte_playin_details

