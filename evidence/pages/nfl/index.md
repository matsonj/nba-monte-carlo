---
queries:
  - thru_date: nfl/thru_date.sql
  - seed_details: nfl/seed_details.sql
  - wins_seed_bar: nfl/wins_seed_bar.sql
---

# NFL Monte Carlo Simulator

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
            data={wins_seed_bar.filter(d => d.conf === "AFC")} 
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
            data={wins_seed_bar.filter(d => d.conf === "NFC")} 
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

🏈 [Teams](/nfl/teams) 🏈 

 </center>