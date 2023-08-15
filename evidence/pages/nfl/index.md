# NFL Monte Carlo Simulator

```reg_season
select
  conf,
  team,
  avg_wins,
  COALESCE(first_round_bye / 10000.0,0) as first_round_bye_pct1,
  COALESCE((first_round_bye + made_postseason) / 10000.0,0) as make_playoffs_pct1
from nfl_reg_season_summary
order by conf, avg_wins desc
```

```AFC_conf
select
  '[' || team || '](/teams/' || team || ')' as team_link,
  team,
  avg_wins,
  first_round_bye_pct1,
  make_playoffs_pct1
from ${reg_season}
WHERE conf = 'AFC'
```

```NFC_conf
select
  '[' || team || '](/teams/' || team || ')' as team_link,
  team,
  avg_wins,
  first_round_bye_pct1,
  make_playoffs_pct1
from ${reg_season}
WHERE conf = 'NFC'
```

```seed_details
SELECT
    winning_team as team,
    season_rank as seed,
    conf,
    count(*) / 10000.0 as occurances_pct1
FROM nfl_reg_season_end
GROUP BY ALL
ORDER BY seed, count(*) DESC
```

```wins_seed_scatter
SELECT
    winning_team as team,
    conf,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank = 1 then 'first round bye'
        when season_rank between 2 and 7 then 'made playoffs'
        else 'missed playoffs'
    end as season_result,
    Count(*) FILTER (WHERE COALESCE(season_rank,100) = 1) AS sort_key
FROM nfl_reg_season_end
GROUP BY ALL
ORDER BY sort_key desc
```

```thru_date
SELECT CURRENT_DATE as end_date
```
## Conference Summaries

<Alert status="info">
This data was last updated as of <Value data={thru_date} column=end_date/>.
</Alert>

### End of Season Seeding

<Tabs>
    <Tab label="AFC">
        <AreaChart
            data={seed_details.filter(d => d.conf === "AFC")} 
            x=seed
            y=occurances_pct1
            series=team
            xAxisTitle=seed
            title='American Conference'
            yMax=1
        />
    </Tab>

    <Tab label="NFC">
        <AreaChart
            data={seed_details.filter(d => d.conf === "NFC")} 
            x=seed
            y=occurances_pct1
            series=team
            xAxisTitle=seed
            title='National Conference'
            yMax=1
        />
    </Tab>
</Tabs>

### End of Season Playoff Odds

<Tabs>
    <Tab label="AFC">
        <BarChart
            data={wins_seed_scatter.filter(d => d.conf === "AFC")} 
            x=team
            y=odds_pct1
            series=season_result
            xAxisTitle=seed
            title='American Conference'
            swapXY=true
            sort=sort_key
        />
    </Tab>

    <Tab label="NFC">
        <BarChart
            data={wins_seed_scatter.filter(d => d.conf === "NFC")} 
            x=team
            y=odds_pct1
            series=season_result
            xAxisTitle=seed
            title='National Conference'
            swapXY=true
            sort=sort_key
        />
    </Tab>
</Tabs>

<center>

🏀 [Teams](/nfl/teams) 🏀 

 </center>