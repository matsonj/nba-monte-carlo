```future_games
SELECT
    date,
    visiting_team as visitor,
    visiting_team_elo_rating AS visitor_ELO,
    home_team as home, 
    home_team_elo_rating AS home_ELO,
    home_team_win_probability/10000 AS home_team_win_pct1,
    american_odds
FROM reg_season_predictions
WHERE include_actuals = false AND winning_team = home_team and type = 'tournament'
ORDER BY game_id
```

```past_games
SELECT *,
    CASE
        WHEN (home_team_win_probability > 5000.0 AND winning_team = home_team)
            OR (home_team_win_probability < 5000.0 AND winning_team = visiting_team)
            THEN 1 ELSE 0 END AS 'accurate_guess'
FROM reg_season_predictions
WHERE include_actuals = true and type = 'tournament'
ORDER BY game_id
```

```standings
WITH cte_wins AS (
    SELECT
        S.winning_team,
        COUNT(*) AS wins
    FROM ${past_games} S
    GROUP BY ALL
),
cte_losses AS (
    SELECT
        CASE WHEN S.home_team = S.winning_team 
            THEN S.visiting_team ELSE S.home_team
        END AS losing_team,
        COUNT(*) AS losses
    FROM ${past_games} S
    GROUP BY ALL
)
SELECT 
    T.team,
    '/nba/teams/' || T.team as team_link,
    T.conf,
    COALESCE(W.wins,0) AS wins,
    COALESCE(L.losses,0) as losses,
    COALESCE(W.wins,0) || '-' || COALESCE(L.losses,0) AS record,
    T.tournament_group as group,
    R.won_group AS won_group_pct1,
    R.made_wildcard AS won_wildcard_pct1,
    R.made_tournament AS made_tournament_pct1,
    ROUND(R.wins,1) || '-' || ROUND(R.losses,1) AS proj_record 
FROM nba_teams T
    LEFT JOIN cte_wins W ON W.winning_team = T.team
    LEFT JOIN cte_losses L ON L .losing_team = T.team
    LEFT JOIN ${tournament_results} R ON R.winning_team = T.team
GROUP BY ALL
ORDER BY T.tournament_group, made_tournament_pct1 DESC
```


```tournament_results
FROM tournament_end
SELECT
    winning_team,
    tournament_group,
    sum(made_tournament) / 10000.0 as won_group,
    sum(made_wildcard) / 30000.0 as made_wildcard,
    sum(made_tournament) / 10000.0 + sum(made_wildcard) / 30000.0 as made_tournament,
    avg(wins) as wins,
    avg(losses) as losses
GROUP BY ALL
ORDER BY tournament_group, made_tournament DESC
```

```most_recent_games
SELECT
    game_date as date,
    vstm as visiting_team,
    '@' as " ",
    hmtm as home_team,
    home_team_score || ' - ' || visiting_team_score as score,
    winning_team,
    ABS(elo_change) AS elo_change_num1
FROM nba_results_log RL
WHERE RL.type = 'tournament'
ORDER BY game_date desc
```

# NBA In-season Tournament

New for the 2023-2024 season, the NBA has introduced an In-Season Tournament. The tournament consists of Group Play followed by single elimination knock out rounds. You can learn about it [here](https://www.nba.com/news/in-season-tournament-101).

## Standings

_It should be noted that predicted results do not have tiebreakers applied._
<Tabs>
    <Tab label="East">

        ### Group A Standings

        <DataTable data={standings.filter(d => d.group === "east_a")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group B Standings

        <DataTable data={standings.filter(d => d.group === "east_b")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group C Standings

        <DataTable data={standings.filter(d => d.group === "east_c")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

    </Tab>
    <Tab label="West">

        ### Group A Standings

        <DataTable data={standings.filter(d => d.group === "west_a")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group B Standings

        <DataTable data={standings.filter(d => d.group === "west_b")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

        ### Group C Standings

        <DataTable data={standings.filter(d => d.group === "west_c")} link=team_link rows=5>
        <Column id=team/>
        <Column id=record/>
        <Column id=proj_record/>
        <Column id=won_group_pct1/>
        <Column id=won_wildcard_pct1/>
        <Column id=made_tournament_pct1/>
        </DataTable>

    </Tab>
</Tabs>

## Recent Games

<DataTable
    data={most_recent_games} 
    rows=5
/>

## Upcoming Games

<DataTable
    data={future_games} 
/>

## Predicted Matchups - Knockout Round

Once I have a good method to predict winnders of each group and break ties, I will add probabilities for each of the 9 games in the tournament, both which teams will play in the games as well as the predicted winners.