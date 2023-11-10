---
sources:
  - future_games: nba/future_games.sql
  - past_games: nba/past_games.sql
  - tournament_standings: nba/tournament_standings.sql
  - tournament_results: nba/tournament_results.sql
  - most_recent_games: nba/most_recent_games.sql
---

```wildcard_standings
SELECT *
FROM ${tournament_standings}
ORDER BY conf, wins DESC, margin DESC
```

# NBA In-season Tournament

New for the 2023-2024 season, the NBA has introduced an In-Season Tournament. The tournament consists of Group Play followed by single elimination knock out rounds. You can learn about it [here](https://www.nba.com/news/in-season-tournament-101).

## Standings

_It should be noted that predicted results do not have tiebreakers applied._
<Tabs>
    <Tab label="East">

        ### Group A Standings

        <DataTable data={tournament_standings.filter(d => d.group === "east_a")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group B Standings

        <DataTable data={tournament_standings.filter(d => d.group === "east_b")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group C Standings

        <DataTable data={tournament_standings.filter(d => d.group === "east_c")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Wildcard Standings

        <DataTable data={wildcard_standings.filter(d => d.conf === "East")} link=team_link rows=15>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>
        
    </Tab>
    <Tab label="West">

        ### Group A Standings

        <DataTable data={tournament_standings.filter(d => d.group === "west_a")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group B Standings

        <DataTable data={tournament_standings.filter(d => d.group === "west_b")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group C Standings

        <DataTable data={tournament_standings.filter(d => d.group === "west_c")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Wildcard Standings

        <DataTable data={wildcard_standings.filter(d => d.conf === "West")} link=team_link rows=15>
        <Column id=team/>
        <Column id=record/>
        <Column id=pt_diff align=right/>
        <Column id=proj_record align=right/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

    </Tab>
</Tabs>

## Recent Games

<DataTable data={most_recent_games.filter(d => d.type === "tournament")} rows=5>
  <Column id=date/>
  <Column id=visiting_team/>
  <Column id=" "/>
  <Column id=home_team/>
  <Column id=winning_team/>
  <Column id=score/>
</DataTable>

## Upcoming Games

<DataTable data={future_games.filter(d => d.type === "tournament")} >
  <Column id=game_id/>
  <Column id=visitor/>
  <Column id=visitor_ELO title="Elo Rtg"/>
  <Column id=home/>
  <Column id=home_ELO title="Elo Rtg"/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line_num1 title="Line (Home)"/>
  <Column id=predicted_score title="Score"/>
</DataTable>


## Predicted Matchups - Knockout Round

Once I have a good method to predict winnders of each group and break ties, I will add probabilities for each of the 9 games in the tournament, both which teams will play in the games as well as the predicted winners.