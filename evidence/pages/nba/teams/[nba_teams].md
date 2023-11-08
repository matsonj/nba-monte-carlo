---
sources:
  - season_summary: nba/season_summary.sql
  - records_table: nba/records_table.sql
  - elo_latest: nba/elo_latest.sql
  - seed_details: nba/seed_details.sql
  - wins_details: nba/wins_details.sql
  - wins_seed_scatter: nba/wins_seed_scatter.sql
  - playoff_odds: nba/playoff_odds.sql
  - most_recent_games: nba/most_recent_games.sql
  - game_trend: nba/game_trend.sql
---

# Detailed Analysis for <Value data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase().replace(/\/+$/,""))} column=team_long/>

## Season-to-date Results

<BigValue 
    data={elo_latest.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='elo_rating' 
    comparison='since_start' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='predicted_wins' 
    comparison='vs_vegas_num1' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='seed_range' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='win_range' 
/> 

<LineChart
    data={game_trend.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    x=date
    y=cumulative_elo_change_num0
    title='elo change over time'
/>

### Most Recent Games

<DataTable
    data={most_recent_games.filter(d => d.home_team === $page.params.nba_teams.toUpperCase() | d.visiting_team === $page.params.nba_teams.toUpperCase())} 
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

<DataTable
    data={records_table.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    rows=7
/>


### Playoff Odds

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='top_six_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='play_in_pct1' 
/> 

<BigValue 
    data={playoff_odds.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
    value='missed_playoffs_pct1' 
/> 

<AreaChart 
    data={wins_seed_scatter.filter(d => d.team === $page.params.nba_teams.toUpperCase())}
    x=wins
    y=odds_pct1
    series=season_result
    xAxisTitle=wins
    title='projected end of season wins'
/>

<BarChart 
    data={seed_details.filter(d => d.team === $page.params.nba_teams.toUpperCase())} 
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