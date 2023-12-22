select
  conf,
  team,
  avg_wins,
  COALESCE(first_round_bye / 10000.0,0) as first_round_bye_pct1,
  COALESCE((first_round_bye + made_postseason) / 10000.0,0) as make_playoffs_pct1
from src_nfl_reg_season_summary
order by conf, avg_wins desc
