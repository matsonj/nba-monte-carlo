MODEL (
  name nba.raw_team_ratings,
  kind SEED (
    path '../../../data/nba/nba_team_ratings.csv'
  ),
  audits (
    number_of_rows(threshold=1)
  )
);