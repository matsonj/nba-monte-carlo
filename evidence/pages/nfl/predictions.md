---
sources:
  - future_games: nfl/future_games.sql
  - past_games: nfl/past_games.sql
  - past_games_summary: nfl/past_games_summary.sql
  - past_games_summary_by_team: nfl/past_games_summary_by_team.sql
---

# Predictions

{#if past_games_summary.length == 0}

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
/> 

<DataTable
    data={past_games_summary_by_team}
    title='Prediction Accuracy by Team'
    rows=30
/>

{/if}
## Future Predictions

_Home field advantage has not been included in these predictions. Historically, NFL teams win 57.5% of their games at home._

<DataTable
    data={future_games}
    title='Predictions'
    rows=16
    rowShading="true" 
    rowLine="false">
    <Column id="visitor"/>
    <Column id="visitor_ELO"/>
    <Column id="home"/>
    <Column id="home_ELO"/>
    <Column id="home_win_pct1"/>
    <Column id="odds" align="right"/>
</DataTable>
