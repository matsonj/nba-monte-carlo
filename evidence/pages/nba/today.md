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

dayjs.extend(utc);
dayjs.extend(timezone);

let today = dayjs().tz('America/Los_Angeles').format('YYYY-MM-DD');
let yesterday = dayjs().tz('America/Los_Angeles').subtract(1, 'day').format('YYYY-MM-DD');
let two_days_ago = dayjs().tz('America/Los_Angeles').subtract(2, 'day').format('YYYY-MM-DD');
</script>

# NBA Today

## Games
<DataTable data={future_games.filter(d => dayjs(d.date).tz('America/Los_Angeles').format('YYYY-MM-DD') < today)} rows=15 link=game_link wrapTitles=true>
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
    data={most_recent_games.filter(d => dayjs(d.date).tz('America/Los_Angeles').format('YYYY-MM-DD') < yesterday && dayjs(d.date).tz('America/Los_Angeles').format('YYYY-MM-DD') >= two_days_ago)}
    rows=12
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

<DataTable data={summary_by_team} link=team_link rows=5 search=true wrapTitles=true>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins title="Avg. Wins"/>
  <Column id=elo_vs_vegas_num1 contentType=delta title="Elo vs. Vegas"/>
  <Column id=make_playoffs_pct1 title="Make Playoffs (%)"/>
  <Column id=win_finals_pct1 title = "Make Finals (%)" />
</DataTable>
