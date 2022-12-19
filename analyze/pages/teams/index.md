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
  '[' || team || '](/teams/' || team || ')' as team_link,
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
  '[' || team || '](/teams/' || team || ')' as team_link,
  team,
  elo_rating,
  avg_wins,
  make_playoffs_pct1,
  win_finals_pct1
from ${reg_season}
WHERE conf = 'West'
```

## team browser
### Eastern Conference
{#each east_conf as record}

[{record.team}](/teams/{record.team}): <Value data={record} column=avg_wins/> avg. wins, <Value data={record} column=elo_rating/> elo, _<Value data={record} column=win_finals_pct1/> chance to win finals_  

{/each}

### Western Conference
{#each west_conf as record}

[{record.team}](/teams/{record.team}): <Value data={record} column=avg_wins/> avg. wins, <Value data={record} column=elo_rating/> elo, _<Value data={record} column=win_finals_pct1/> chance to win finals_  

{/each}
