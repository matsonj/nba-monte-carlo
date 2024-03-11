MODEL (
  name nba.teams,
  kind VIEW
);

SELECT
    R.team_long,
    R.team,
    tournament_group,
    conf
FROM nba.raw_team_ratings R;