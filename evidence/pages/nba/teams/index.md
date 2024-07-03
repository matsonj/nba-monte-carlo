---
queries:
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
---

# Team Browser
## Select a conference

```sql filtered_summary_by_team
    select * 
    from ${summary_by_team}
    where conf like '${inputs.conference}'
```

<ButtonGroup
    data={summary_by_team} 
    name=conference
    value=conf
>
    <ButtonGroupItem valueLabel="All" value="%" default />
</ButtonGroup>

{#if inputs.conference != 'null'}

<DataTable data={filtered_summary_by_team} link=team_link rows=30>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=elo_vs_vegas_num1 contentType=delta/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

{:else }

<DataTable data={summary_by_team} link=team_link rows=30>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=elo_vs_vegas_num1 contentType=delta/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

{/if}

