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

```standings
SELECT
    team,
    wins || '-' || losses AS record
FROM reg_season_actuals_enriched
```

```east_conf
select
  '/teams/' || R.team as team_link,
  R.team,
  S.record,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
FROM ${reg_season} R
LEFT JOIN ${standings} S ON S.team = R.team
WHERE conf = 'East'
```

```west_conf
select
  '/teams/' || R.team as team_link,
  R.team,
  S.record,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
FROM ${reg_season} R
LEFT JOIN ${standings} S ON S.team = R.team
WHERE conf = 'West'
```

## Team Browser
### Eastern Conference

<DataTable data={east_conf} link=team_link showLinkCol=false rows=15/>

### Western Conference

<DataTable data={west_conf} link=team_link showLinkCol=false rows=15/>
