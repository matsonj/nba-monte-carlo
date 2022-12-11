# NBA Monte Carlo Simulator

Welcome to the [NBA monte carlo simulator](https://github.com/matsonj/nba-monte-carlo) project. Evidence is used as the as data visualization & analysis part of [MDS in a box](http://mdsinabox.com).

## Conference leaders
- <Value data={east_conf} column=team /> 
leads the Eastern Conference with <Value data={east_conf} column=avg_wins /> Expected Wins.
- <Value data={west_conf} column=team /> leads the Western Conference with <Value data={west_conf} column=avg_wins /> Expected Wins.

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

## Team Index
<sub>Each team is summarized in the index. Click on a specific team to drill down to their analytical page.</sub>

## Eastern Conference
{#each east_conf as record}

[{record.team}](/teams/{record.team}): <Value data={record} column=avg_wins/> avg. wins, <Value data={record} column=elo_rating/> elo, _<Value data={record} column=win_finals_pct1/> chance to win finals_  

{/each}

## Western Conference
{#each west_conf as record}

[{record.team}](/teams/{record.team}): <Value data={record} column=avg_wins/> avg. wins, <Value data={record} column=elo_rating/> elo, _<Value data={record} column=win_finals_pct1/> chance to win finals_  

{/each}
