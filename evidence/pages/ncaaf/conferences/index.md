---
queries:
  - conf_summary: ncaaf/past_games_by_conference.sql
---

<DataTable
    data={conf_summary}
    title='Conference Standings'
    rows=16
    rowShading="true" 
    rowLine="false"
    link="team_link">
    <Column id="conf"/>
    <Column id="teams"/>
    <Column id="record"/>
    <Column id="avg_elo_rating" title="Avg ELO"/>
    <Column id="tot_wins"/>
    <Column id="vegas_wins"/>
    <Column id="elo_vs_vegas_num1" contentType=delta/>
</DataTable>

_Not all teams had vegas win totals provided, which explains why total wins compared to vegas wins doesn't match perfectly for some conferences._