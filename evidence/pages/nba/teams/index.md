---
sources:
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
---

# Team Browser
## Eastern Conference

<DataTable data={summary_by_team.filter(d => d.conf === "East")} link=team_link rows=15>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

## Western Conference

<DataTable data={summary_by_team.filter(d => d.conf === "West")} link=team_link rows=15>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>