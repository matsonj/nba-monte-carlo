
  create view "main"."initialize_seeding__dbt_tmp" as (
    WITH cte_teams AS (
    SELECT scenario_id,
        conf,
        winning_team,
        seed
    FROM "main"."main"."reg_season_end"
    WHERE season_rank < 7
    UNION ALL 
    SELECT *
    FROM "main"."main"."playin_r2_end"
)
SELECT T.*,
    R.elo_rating
FROM cte_teams T
    LEFT JOIN "main"."main"."ratings" R ON T.winning_team = R.team
  );
