---
queries:
  - season_summary: nba/season_summary.sql
  - records_table: nba/records_table.sql
  - elo_latest: nba/elo_latest.sql
  - seed_details: nba/seed_details.sql
  - wins_details: nba/wins_details.sql
  - playoff_wins: nba/playoff_odds_by_team_by_wins.sql
  - playoff_odds: nba/playoff_odds.sql
  - most_recent_games: nba/most_recent_games.sql
  - game_trend: nba/game_trend.sql
  - future_games: nba/future_games.sql
title: Team Details
---

```sql filtered_season_summary
    select *
    from ${season_summary}
    where team like '${params.nba_teams.toUpperCase()}'
```

# Detailed Analysis for <Value data={filtered_season_summary} column=team_long/>

## Season-to-date Results

<BigValue 
    data={elo_latest.filter(d => d.team === params.nba_teams.toUpperCase())} 
    value='elo_rating' 
    comparison='since_start' 
/> 

<BigValue 
    data={filtered_season_summary} 
    value='predicted_wins' 
    comparison='vs_vegas_num1'
    comparisonTitle='vs. Vegas'
/> 

<BigValue 
    data={filtered_season_summary} 
    value='seed_range' 
/> 

<BigValue 
    data={filtered_season_summary} 
    value='win_range' 
/> 

<LineChart
    data={game_trend.filter(d => d.team === params.nba_teams.toUpperCase())} 
    x=date
    y=cumulative_elo_change_num0
    title='elo change over time'
/>

### Most Recent Games

<DataTable
    data={most_recent_games.filter(d => d.home_team === params.nba_teams.toUpperCase() | d.visiting_team === params.nba_teams.toUpperCase())} 
    rows=5
>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visiting_team/>
  <Column id=" "/>
  <Column id=home_team/>
  <Column id=winning_team/>
  <Column id=score/>
</DataTable>


### Matchup Summary

<DataTable data={records_table.filter(d => d.team === params.nba_teams.toUpperCase())} rows=7>
    <Column id=team/>
    <Column id=type/>
    <Column id=wins/>
    <Column id=losses/>
    <Column id=win_pct_num3 title="Win %"/>
</DataTable>

{#if future_games.length > 0}
### Upcoming Schedule

<DataTable data={future_games.filter(d => d.home === params.nba_teams.toUpperCase() | d.visitor === params.nba_teams.toUpperCase())} rows=5 link=game_link>
<!-- <DataTable data={future_games.filter(d => d.home === params.nba_teams.toUpperCase() | d.visitor === params.nba_teams.toUpperCase())} rows=5> -->
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visitor/>
  <Column id=home/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line_num1 title="Line (Home)"/>
  <Column id=predicted_score title="Score"/>
</DataTable>

### Playoff Odds

<BigValue 
    data={playoff_odds.filter(d => d.team === params.nba_teams.toUpperCase())} 
    value='top_six_pct1'
    title='Top 6 Seed (%)' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === params.nba_teams.toUpperCase())} 
    value='play_in_pct1'
    title='Play-in (%)'
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === params.nba_teams.toUpperCase())} 
    value='missed_playoffs_pct1'
    title='Miss Playoffs (%)'
/> 

<AreaChart 
    data={playoff_wins.filter(d => d.team === params.nba_teams.toUpperCase())}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='projected end of season wins'
    seriesColors={{'missed playoffs':'#9fadbd','play in':'#3b4856','top six seed':'#0777b3'}}
/>

<BarChart 
    data={seed_details.filter(d => d.team === params.nba_teams.toUpperCase())} 
    x=seed
    y=occurances_pct1
    xAxisTitle=seed
    title='projected end of season seeding'
/>

{#if game_trend.length == 0}

## Playoff Analysis

add the following:
- play-in analysis (if playin games exist, i.e. count > 1)
  - this will show % of time by spot, and then % of advancing by seed
- playoff analysis
  - most common opponents with win rate by series (mostly nulls, sparsely populated)


  {/if}
  {/if}