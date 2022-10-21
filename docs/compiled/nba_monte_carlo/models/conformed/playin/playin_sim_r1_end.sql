

WITH cte_playin_details AS (
    SELECT
        S.scenario_id,
        S.game_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS winning_team_elo_rating,
        S.conf AS conf,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_team
            ELSE S.home_team
        END AS losing_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_team_elo_rating
            ELSE S.home_team_elo_rating
        END AS losing_team_elo_rating,
        CASE
            WHEN S.game_id IN (1231, 1234) THEN 'winner advance'
            WHEN S.game_id IN (1232, 1235) THEN 'loser eliminated'
        END AS result
    FROM "main"."main_main"."playin_sim_r1" S
)

SELECT
    *,
    CASE
        WHEN game_id IN (1231, 1234) THEN losing_team
        WHEN game_id IN (1232, 1235) THEN winning_team
    END AS remaining_team
FROM cte_playin_details