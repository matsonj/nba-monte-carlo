
  create view "main"."ratings__dbt_tmp" as (
    SELECT
    orig.team,
    orig.team_long,
    orig.conf,
    CASE
        WHEN latest.latest_ratings = true AND latest.elo_rating IS NOT NULL THEN latest.elo_rating
        ELSE orig.elo_rating
    END AS elo_rating,
    orig.elo_rating AS original_rating,
    orig.win_total
FROM "main"."main"."prep_team_ratings" orig
LEFT JOIN "main"."main"."prep_elo_post" latest ON latest.team = orig.team
GROUP BY ALL
  );
