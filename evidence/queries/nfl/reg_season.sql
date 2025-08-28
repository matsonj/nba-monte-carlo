select
  conf,
  s.team,
  case 
    when team_short = 'JAC' then 'JAX'
    when team_short = 'STL' then 'LA'
    when team_short = 'SD' then 'LAC'
    when team_short = 'OAK' then 'LV'
    when team_short = 'TB' then 'TAM'
    when team_short = 'WAS' then 'WSH'
    else team_short
  end as team_espn_code,
  'https://secure.espn.com/combiner/i?img=/i/teamlogos/nfl/500/' || team_espn_code || '.png&w=56&h=56' as " ",
  elo_rating,
  avg_wins,
  COALESCE(made_playoffs / 10000.0,0) as make_playoffs_pct1,
  COALESCE(won_finals / 10000.0,0) as win_finals_pct1,
  elo_vs_vegas *-1 as elo_vs_vegas
from src_nfl_season_summary s
left join src_nfl_teams t on t.team = s.team
order by conf, avg_wins desc
