{{ 
    config(
        materialized='external',
        location="../data/data_catalog/simulator/{{this.name}}.parquet")
}}

WITH cte_wins AS (
    SELECT
        S.scenario_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_conf
            ELSE S.visiting_conf
        END AS conf,
      /*  CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS elo_rating, */
        COUNT(*) AS wins
    FROM {{ ref( 'nfl_reg_season_simulator' ) }} S
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
            WHEN season_rank = 1 THEN 1
            ELSE 0
        END AS first_round_bye,
        CASE
            WHEN season_rank BETWEEN 1 AND 7 THEN 1
            ELSE 0
        END AS made_playoffs,
        conf || '-' || season_rank::text AS seed
    FROM cte_ranked_wins
)

SELECT 
    MP.*,
    LE.elo_rating,
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM cte_made_playoffs MP
LEFT JOIN {{ ref( 'nfl_latest_elo' ) }} LE ON LE.team = MP.winning_team