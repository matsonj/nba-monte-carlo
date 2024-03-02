---
queries:
  - top_25: ncaaf/top_25.sql
  - thru_date: ncaaf/thru_date.sql
---

# NCAA College Football Monte Carlo Simulator - 2023 Season

## Conference Summaries

<Alert status="info">
This data was last updated as of <Value data={thru_date} column=end_date/>.
</Alert>

### Top 25 Teams

<DataTable data={top_25} link=team_link rows=25
  rowShading="true">
  <Column id=Rk/>
  <Column id=team/>
  <Column id=conf/>
  <Column id=record/>
  <Column id=elo_rating_num0/>
  <Column id=avg_wins_num1/>
</DataTable>

<center>

🏈 [Predictions](/ncaaf/predictions) 🏈 

 </center>