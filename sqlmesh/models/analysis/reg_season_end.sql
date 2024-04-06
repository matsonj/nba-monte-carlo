MODEL (
  name nba.reg_season_end,
  kind FULL
);

WITH cte_wins AS (
    SELECT
        S.scenario_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_conf
            ELSE S.visiting_conf
        END AS conf,
        COUNT(*) AS wins
    FROM nba.reg_season_simulator S
    GROUP BY ALL
),

cte_ranked_wins AS (
    SELECT
        *,
        --no tiebreaker, so however row number handles order ties will need to be dealt with
        ROW_NUMBER() OVER (PARTITION BY scenario_id, conf ORDER BY wins DESC, winning_team DESC ) AS season_rank
    FROM cte_wins

),

cte_made_playoffs AS (
    SELECT
        *,
        CASE
            WHEN season_rank <= 10 THEN 1
            ELSE 0
        END AS made_playoffs,
        CASE
            WHEN season_rank BETWEEN 7 AND 10 THEN 1
            ELSE 0
        END AS made_play_in,
        conf || '-' || season_rank::text AS seed
    FROM cte_ranked_wins
)

SELECT 
    MP.*,
    LE.elo_rating,
    0 AS sim_start_game_id
FROM cte_made_playoffs MP
LEFT JOIN nba.latest_elo LE ON LE.team = MP.winning_team;
