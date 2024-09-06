---
queries:
  - all_teams: nfl/all_teams.sql
---

```afc_conf
select
  ROW_NUMBER() OVER (ORDER BY avg_wins_num1 DESC) AS seed,
  *
FROM ${all_teams} R
WHERE conf = 'AFC'
ORDER BY avg_wins_num1 DESC
```

```nfc_conf
select
  ROW_NUMBER() OVER (ORDER BY avg_wins_num1 DESC) AS seed,
  *
FROM ${all_teams} R
WHERE conf = 'NFC'
ORDER BY avg_wins_num1 DESC
```

# NFL Teams
## American Football Conference

 <DataTable data={afc_conf} link=team_link rows=16 rowShading="true">
  <Column id=seed/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating_num0 title='ELO rating'/>
  <Column id=avg_wins_num1 title='Avg. Wins'/>
  <Column id=make_playoffs_pct1 title='Playoff Odds (%)'/>
</DataTable>

## National Football Conference

 <DataTable data={nfc_conf} link=team_link rows=16 rowShading="true">
  <Column id=seed/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating_num0 title='ELO rating'/>
  <Column id=avg_wins_num1 title='Avg. Wins'/>
  <Column id=make_playoffs_pct1 title='Playoff Odds (%)'/>
</DataTable>