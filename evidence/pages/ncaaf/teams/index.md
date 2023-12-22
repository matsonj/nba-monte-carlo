---
queries:
  - all_teams: ncaaf/all_teams.sql
---

# NCAA Teams

## 👉 [Conferences](/ncaaf/conferences)

### Team Standings

<DataTable data={all_teams} link=team_link rows=25 search=true
    title='Team Standings'>
  <Column id=Rk/>
  <Column id=team/>
  <Column id=conf/>
  <Column id=record/>
  <Column id=elo_rating_num0/>
  <Column id=avg_wins_num1/>
</DataTable>