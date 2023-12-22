select
  conf,
  team,
  avg_wins,
  elo_rating,
  win_range,
  seed_range,
  vegas_wins,
  record,
  elo_vs_vegas*-1 as elo_vs_vegas_num1,
  '/ncaaf/teams/' || team as team_link,
  COALESCE(first_round_bye / 10000.0,0) as first_round_bye_pct1,
  COALESCE((first_round_bye + made_postseason) / 10000.0,0) as make_playoffs_pct1
from src_ncaaf_reg_season_summary
order by conf, avg_wins desc
