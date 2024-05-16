---
queries:
  - all_teams: nfl/all_teams.sql
  - season_summary: nfl/reg_season.sql
  - elo_latest: nfl/elo_latest.sql
  - most_recent_games: nfl/most_recent_games.sql
  - game_trend: nfl/game_trend.sql
---

# Detailed Analysis for <Value data={all_teams.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} column=team/>

```nfl_season_summary
select R.*,
    R.elo_vs_vegas*-1.0 as vs_vegas_num1,
    R.avg_wins as predicted_wins,
    (COALESCE(R.made_postseason,0) + COALESCE(R.first_round_bye,0) )/ 10000.0 as made_playoffs_pct1
from src_nfl_reg_season_summary R
left join src_nfl_ratings T on R.team = T.team
```

```nfl_wins_seed_scatter
SELECT
    winning_team as team,
    wins as wins,
    count(*) / 10000.0 as odds_pct1,
    case when season_rank = 1 then 'first round bye'
        when season_rank between 2 and 7 then 'made playoffs'
        else 'missed playoffs'
    end as season_result
FROM src_nfl_reg_season_end
GROUP BY ALL
```

```nfl_playoff_odds
SELECT 
    team,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'first round bye'),0) as first_rd_bye_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'made playoffs'),0) as made_playoffs_pct1,
    COALESCE(SUM(odds_pct1) FILTER (WHERE season_result = 'missed playoffs'),0) as missed_playoffs_pct1
FROM ${nfl_wins_seed_scatter}
GROUP BY ALL
```

```nfl_seed_details
SELECT
    winning_team as team,
    season_rank as seed,
    count(*) / 10000.0 as occurances_pct1
FROM src_nfl_reg_season_end
GROUP BY ALL
```

## Season-to-date Results

{#if elo_latest.length > 0}
<BigValue 
    data={elo_latest.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}
    value='elo_rating' 
    comparison='since_start_num1' 
/>
{/if}

<BigValue 
    data={nfl_season_summary.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    value='predicted_wins' 
    comparison='vs_vegas_num1' 
/> 
<BigValue 
    data={nfl_season_summary.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    value='seed_range' 
/> 

<BigValue 
    data={nfl_season_summary.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    value='win_range' 
/>
{#if game_trend.length > 0}
<LineChart
    data={game_trend.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    x=week
    y=cumulative_elo_change_num0
    title='elo change over time'
    xMax=12
/>

### Most Recent Games

<DataTable
    data={most_recent_games.filter(d => d.home_team.toUpperCase() === $page.params.nfl_teams.toUpperCase() | d.visiting_team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    rows=12
/>
{:else}

_The regular season has yet to begin. Check back soon!_

{/if}

### Playoff Odds

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='first_rd_bye_pct1' 
/> 

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='made_playoffs_pct1' 
/> 

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='missed_playoffs_pct1' 
/> 

<AreaChart 
    data={nfl_wins_seed_scatter.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='projected end of season wins'
/>

<BarChart 
    data={nfl_seed_details.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    x=seed
    y=occurances_pct1
    xAxisTitle=seed
    title='projected end of season seeding'
/>
