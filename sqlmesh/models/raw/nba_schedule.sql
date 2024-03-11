MODEL (
  name nba.raw_schedule,
  kind SEED (
    path '../../../data/nba/nba_schedule.csv'
  ),
  audits (
    number_of_rows(threshold=1)
  )
);