
  create view "main"."post_season_schedule__dbt_tmp" as (
    SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM "main"."main"."prep_schedule" AS S
WHERE S.type <> 'reg_season'
GROUP BY ALL
  );
