# NBA Monte Carlo Simulator

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

```seed_details
SELECT
    winning_team as team,
    season_rank as seed,
    conf,
    count(*) / 10000.0 as occurances_pct1
FROM reg_season_end
GROUP BY ALL
ORDER BY seed, count(*) DESC
```

```wins_seed_scatter
SELECT
    winning_team as team,
    conf,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank <= 6 then 'top six seed'
        when season_rank between 7 and 10 then 'play in'
        else 'missed playoffs'
    end as season_result,
    Count(*) FILTER (WHERE season_rank <=6)*-1 AS sort_key
FROM reg_season_end
GROUP BY ALL
ORDER BY sort_key
```

```thru_date
SELECT COALESCE(max(game_date),CURRENT_DATE) as end_date FROM nba_latest_results
```
## Conference Summaries

<Alert status="info">
This data was last updated as of <Value data={thru_date} column=end_date/>.
</Alert>

### End of Season Seeding

<Tabs>
    <Tab label="East">
        <AreaChart
            data={seed_details.filter(d => d.conf === "East")} 
            x=seed
            y=occurances_pct1
            series=team
            xAxisTitle=seed
            title='Eastern Conference'
            yMax=1
        />
    </Tab>

    <Tab label="West">
        <AreaChart
            data={seed_details.filter(d => d.conf === "West")} 
            x=seed
            y=occurances_pct1
            series=team
            xAxisTitle=seed
            title='Western Conference'
            yMax=1
        />
    </Tab>
</Tabs>

### End of Season Playoff Odds

<Tabs>
    <Tab label="East">
        <BarChart
            data={wins_seed_scatter.filter(d => d.conf === "East")} 
            x=team
            y=odds_pct1
            series=season_result
            xAxisTitle=seed
            title='Eastern Conference'
            swapXY=true
            sort=sort_key
        />
    </Tab>

    <Tab label="West">
        <BarChart
            data={wins_seed_scatter.filter(d => d.conf === "West")} 
            x=team
            y=odds_pct1
            series=season_result
            xAxisTitle=seed
            title='Western Conference'
            swapXY=true
            sort=sort_key
        />
    </Tab>
</Tabs>

<center>

🏀 [Teams](/nba/teams) 🏀 

 </center>