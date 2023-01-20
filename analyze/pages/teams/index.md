```reg_season
select
  conf,
  team,
  elo_rating,
  avg_wins,
  COALESCE(made_playoffs / 10000.0,0) as make_playoffs_pct1,
  COALESCE(won_finals / 10000.0,0) as win_finals_pct1
from season_summary
order by conf, avg_wins desc
```

```east_conf
select
  '/teams/' || team as team_link,
  team,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
from ${reg_season}
WHERE conf = 'East'
```

```west_conf
select
  '/teams/' || team as team_link,
  team,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
from ${reg_season}
WHERE conf = 'West'
```

## Team Browser
### Eastern Conference

<DataTable data={east_conf} link=team_link showLinkCol=false rows=15/>

### Western Conference

<DataTable data={west_conf} link=team_link showLinkCol=false rows=15/>
