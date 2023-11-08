---
sources:
  - thru_date: nba/thru_date.sql
  - wins_seed_scatter: nba/wins_seed_scatter.sql
  - seed_details: nba/seed_details.sql
---

# NBA Monte Carlo Simulator

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