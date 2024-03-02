---
queries:
  - all_teams: ncaaf/all_teams.sql
  - season_summary: ncaaf/reg_season.sql
  - elo_latest: ncaaf/elo_latest.sql
  - most_recent_games: ncaaf/most_recent_games.sql
  - game_trend: ncaaf/game_trend.sql
---

# Detailed Analysis for <Value data={all_teams.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} column=team/>


## Season-to-date Results

<BigValue 
    data={elo_latest.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())}
    value='elo_rating' 
    comparison='since_start_num1' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} 
    value='avg_wins' 
    comparison='elo_vs_vegas_num1' 
/> 

<BigValue 
    data={season_summary.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} 
    value='seed_range' 
    title='Conf. Seed'
/> 

<BigValue 
    data={season_summary.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} 
    value='win_range' 
/> 

<LineChart
    data={game_trend.filter(d => d.team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} 
    x=week
    y=cumulative_elo_change_num0
    title='elo change over time'
    xMax=12
/>

### Most Recent Games

<DataTable
    data={most_recent_games.filter(d => d.home_team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase() | d.visiting_team.toUpperCase() === $page.params.ncaaf_teams.toUpperCase())} 
    rows=12
/>