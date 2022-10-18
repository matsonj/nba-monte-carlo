
  create view "main"."ratings__dbt_tmp" as (
    





SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating

FROM "main"."main"."raw_team_ratings"

GROUP BY ALL
  );
