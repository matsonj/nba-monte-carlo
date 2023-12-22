---
queries:
  - team_summary: ncaaf/reg_season.sql
---

# Detailed Analysis for <Value data={team_summary.filter(d => d.conf.toUpperCase() === $page.params.ncaaf_conferences.toUpperCase())} column=conf/>

<DataTable
    data={team_summary.filter(d => d.conf.toUpperCase() === $page.params.ncaaf_conferences.toUpperCase())}
    title='Conference Standings'
    rowShading="true" 
    rowLine="false"
    rows=100
    link="team_link">
    <Column id="team"/>
    <Column id="record"/>
    <Column id="elo_rating" title="ELO"/>
    <Column id="avg_wins"/>
    <Column id="vegas_wins"/>
    <Column id="elo_vs_vegas_num1" contentType=delta/>
</DataTable>

_Not all teams had vegas win totals provided, which explains why total wins compared to vegas wins doesn't match perfectly for some conferences._
