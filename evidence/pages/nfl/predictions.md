---
queries:
  - past_games: nfl/past_games.sql
  - past_games_summary: nfl/past_games_summary.sql
  - past_games_summary_by_team: nfl/past_games_summary_by_team.sql
  - future_games: nfl/future_games.sql
  - teams: nfl/all_teams.sql
---

# Predictions

```sql teams
select * from ${teams}
order by team
```

```sql filtered_future_games
    select * EXCLUDE (game_id), game_id::int as game_id
    from ${future_games}
    where home like '${inputs.team_dropdown.value}' OR visitor like '${inputs.team_dropdown.value}'
```

{#if past_games.length > 0}
## Past Performance

<BigValue 
    data={past_games_summary} 
    value='total_games_played' 
/> 

<BigValue 
    data={past_games_summary} 
    value='correct_predictions' 
/> 

<BigValue 
    data={past_games_summary} 
    value='accuracy_pct1'
    title='Accuracy'
    fmt=pct1
/> 

<Accordion>
  <AccordionItem title="Detailed Results by Team">
    <DataTable
        data={past_games_summary_by_team}
        title='Prediction Accuracy by Team'
        rows=32
    />
  </AccordionItem>
</Accordion>

{:else}

_The regular season has yet to begin. Check back soon!_

{/if}

## Future Predictions

_Historically, NFL teams win 57% of their games at home, which explains why teams with lower elo ratings can be predicted to win._

<Dropdown
    data={teams} 
    name=team_dropdown
    value=team
    title="Select a Team"
>
    <DropdownOption valueLabel="All Teams" value="%" />
</Dropdown>

<DataTable data={filtered_future_games} rows=15>
  <Column id=week_number title=week/>
  <Column id=visitor/>
  <Column id=home/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line title="Line (Home)" fmt=num1/>
</DataTable>