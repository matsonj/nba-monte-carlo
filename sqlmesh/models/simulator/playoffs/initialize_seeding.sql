MODEL (
  name nba.initialize_seeding,
  kind FULL
);

WITH cte_teams AS (
    SELECT
        scenario_id,
        conf,
        winning_team,
        seed,
        elo_rating
    FROM nba.reg_season_end
    WHERE season_rank < 7
    UNION ALL
    SELECT *
    FROM nba.playin_sim_r2_end
)

SELECT
    T.*,
    0 AS sim_start_game_id
FROM cte_teams T;
