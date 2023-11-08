select
  ROW_NUMBER() OVER (PARTITION BY conf ORDER BY avg_wins DESC) AS seed,
  '/nba/teams/' || R.team as team_link,
  R.team,
  R." ",
  S.record,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1,
  conf
FROM ${reg_season} R
LEFT JOIN ${standings} S ON S.team = R.team
ORDER BY avg_wins DESC