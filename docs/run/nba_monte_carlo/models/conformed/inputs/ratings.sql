
  create view "main"."ratings__dbt_tmp" as (
    

SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating
FROM "main"."main_prep"."prep_team_ratings"
GROUP BY ALL
  );
