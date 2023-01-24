```reg_season
select
  conf,
  team,
  case 
    when team = 'CHO' then 'CHA'
    when team = 'BRK' then 'BKN'
    when team = 'NOP' then 'NO'
    when team = 'UTA' then 'UTAH'
    else team
  end as team_espn_code,
  'https://secure.espn.com/combiner/i?img=/i/teamlogos/nba/500/' || team_espn_code || '.png&w=56&h=56' as " ",
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
  ROW_NUMBER() OVER (ORDER BY avg_wins DESC) AS seed,
  '/teams/' || R.team as team_link,
  R.team,
  R." ",
  S.record,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
FROM ${reg_season} R
LEFT JOIN ${standings} S ON S.team = R.team
WHERE conf = 'East'
ORDER BY avg_wins DESC
```

```west_conf
select
  ROW_NUMBER() OVER (ORDER BY avg_wins DESC) AS seed,
  '/teams/' || R.team as team_link,
  R.team,
  R." ",
  S.record,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
FROM ${reg_season} R
LEFT JOIN ${standings} S ON S.team = R.team
WHERE conf = 'West'
ORDER BY avg_wins DESC
```

## Team Browser
### Eastern Conference

<DataTable data={east_conf} link=team_link rows=15>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

### Western Conference

<DataTable data={west_conf} link=team_link rows=15>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>