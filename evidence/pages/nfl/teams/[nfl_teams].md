---
queries:
  - all_teams: nfl/all_teams.sql
  - season_summary: nfl/reg_season.sql
  - elo_latest: nfl/elo_latest.sql
  - most_recent_games: nfl/most_recent_games.sql
  - game_trend: nfl/game_trend.sql
  - future_games: nfl/future_games.sql
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
    count(*) / 10000.0 as occurances
FROM src_nfl_reg_season_end
GROUP BY ALL
```

## Season-to-date Results

{#if elo_latest.length > 0}
<BigValue 
    data={elo_latest.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}
    value='elo_rating' 
    comparison='since_start_num1'
    comparisonTitle='Since Start' 
/>
{/if}

<BigValue 
    data={nfl_season_summary.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    value='predicted_wins' 
    comparison='vs_vegas_num1'
    comparisonTitle='vs Vegas Win Total' 
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
    rows=4>
    <Column id=week/>
    <Column id='visiting_team'/>
    <Column id=' '/>
    <Column id='home_team'/>
    <Column id='score'/>
    <Column id='winning_team'/>
    <Column id='elo_change_num1' title='ELO chg.'/>

</DataTable>
{:else}

_The regular season has yet to begin. Check back soon!_

{/if}

{#if future_games.length > 0}
### Upcoming Schedule

<DataTable data={future_games.filter(d => d.home.toUpperCase() === $page.params.nfl_teams.toUpperCase() | d.visitor.toUpperCase() === $page.params.nfl_teams.toUpperCase())} rows=4>
  <Column id=week_number title="Wk"/>
  <Column id=visitor/>
  <Column id=home/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line title="Line (Home)" fmt=num1/>
</DataTable>
{/if}

### Playoff Odds

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='first_rd_bye_pct1'
    title='First Round Bye'
/> 

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='made_playoffs_pct1'
    title='Made Playoffs'
/> 

<BigValue 
    data={nfl_playoff_odds.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}  
    value='missed_playoffs_pct1'
    title='Missed Playoffs' 
/> 

<AreaChart 
    data={nfl_wins_seed_scatter.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='Projected Total Wins'
    seriesColors={{'missed playoffs':'#9fadbd','made playoffs':'#3b4856','first round bye':'#0777b3'}}
/>

<BarChart 
    data={nfl_seed_details.filter(d => d.team.toUpperCase() === $page.params.nfl_teams.toUpperCase())} 
    x=seed
    y=occurances
    yFmt=pct1
    xAxisTitle=seed
    title='Projected End of Season Seed'
/>
