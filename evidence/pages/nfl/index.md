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
            colorPalette={['#064265','#08507c','#0a5d92','#0d6aa9','#1076bf','#1382d4','#178de9','#2f96ea','#479feb','#5ea9ed','#75b3ee','#8cbef0','#a3caf3','#b9d6f5','#cfe2f8','#e5effb']}
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
            colorPalette={['#064265','#08507c','#0a5d92','#0d6aa9','#1076bf','#1382d4','#178de9','#2f96ea','#479feb','#5ea9ed','#75b3ee','#8cbef0','#a3caf3','#b9d6f5','#cfe2f8','#e5effb']}
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
            colorPalette={['#0777b3', '#3b4856','#9fadbd']}
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
            colorPalette={['#0777b3', '#3b4856','#9fadbd']}
        />
    </Tab>
</Tabs>

<center>

🏈 [Teams](/nfl/teams) 🏈 

 </center>