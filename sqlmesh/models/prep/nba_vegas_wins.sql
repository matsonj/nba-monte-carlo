MODEL (
  name nba.vegas_wins,
  kind VIEW
);

SELECT
    team,
    win_total::double as win_total
FROM nba.raw_team_ratings
GROUP BY ALL;
