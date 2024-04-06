MODEL (
  name nba.schedules,
  kind FULL
);

SELECT
    *
FROM nba.reg_season_schedule
UNION ALL
SELECT
    *
FROM nba.post_season_schedule;