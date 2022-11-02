
  create view "main"."schedules__dbt_tmp" as (
    SELECT
    *
FROM "main"."main"."reg_season_schedule"
UNION ALL
SELECT
    *
FROM "main"."main"."post_season_schedule"
  );
