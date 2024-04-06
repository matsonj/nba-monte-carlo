---
queries:
  - thru_date: nba/thru_date.sql
  - wins_seed_scatter: nba/wins_seed_scatter.sql
  - seed_details: nba/seed_details.sql
  - tournament_seeding: nba/tournament_seeding.sql
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
  - future_games: nba/future_games.sql
---

```sql teams
select * from src_nba_teams
order by team
```

```sql filtered_future_games
    select *
    from ${future_games}
    where home like '${inputs.team_dd.value}' OR visitor like '${inputs.team_dd.value}'
```

# NBA Monte Carlo Simulator

<Alert status="info">
This data was last updated as of <Value data={thru_date} column=end_date/>.
</Alert>

## [Upcoming Games](/nba/predictions)

<Dropdown
    data={teams} 
    name=team_dd
    value=team
    title="Select a Team"
>
    <DropdownOption valueLabel="All Teams" value="%" />
</Dropdown>

<DataTable data={filtered_future_games} rows=5 link=game_link>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visitor/>
  <Column id=home/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line_num1 title="Line (Home)"/>
  <Column id=predicted_score title="Score"/>
</DataTable>

## [Team Standings](/nba/teams)

<DataTable data={summary_by_team} link=team_link rows=5 search=true>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=elo_vs_vegas_num1 contentType=delta/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

## Conference Summaries

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

