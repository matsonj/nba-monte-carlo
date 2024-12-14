---
title: Today
queries:
  - future_games: nba/future_games.sql
  - most_recent_games: nba/most_recent_games.sql
  - summary_by_team: nba/summary_by_team.sql
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
sidebar_position: 1
---


<script>
import dayjs from 'dayjs';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

dayjs.extend(utc).extend(timezone);

const pst = date => dayjs(date).tz('America/Los_Angeles').format('YYYY-MM-DD');
const today = pst();
const yesterday = pst(dayjs().subtract(1, 'day'));
const two_days_ago = pst(dayjs().subtract(2, 'day'));
</script>

## Games
<DataTable data={future_games.filter(d => pst(d.date) < today)} rows=15 link=game_link wrapTitles=true rowShading=true rowLines=false>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visitor/>
  <Column id=home/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line_num1 title="Line (Home)"/>
  <Column id=predicted_score title="Score"/>
</DataTable>

## Yesterday's Games
<DataTable
    data={most_recent_games.filter(d => pst(d.date) < yesterday && pst(d.date) >= two_days_ago)}
    rows=12
    rowShading=true rowLines=false wrapTitles=true
>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visiting_team/>
  <Column id=" "/>
  <Column id=home_team/>
  <Column id=winning_team/>
  <Column id=score/>
</DataTable>

## Standings

<DataTable data={summary_by_team} link=team_link rows=15 search=true wrapTitles=true rowShading=true rowLines=false>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins title="Avg. Wins"/>
  <Column id=elo_vs_vegas_num1 contentType=delta title="Elo vs. Vegas"/>
  <Column id=make_playoffs_pct1 title="Make Playoffs (%)"/>
  <Column id=win_finals_pct1 title = "Win Finals (%)" />
</DataTable>
