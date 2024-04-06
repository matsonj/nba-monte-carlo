MODEL (
  name nba.raw_results,
  kind SEED (
    path '../../../data/nba/nba_results.csv'
  ),
  audits (
    number_of_rows(threshold=1)
  )
);