---
sources:
  - future_games: ncaaf/future_games.sql
  - past_games: ncaaf/past_games.sql
  - past_games_summary: ncaaf/past_games_summary.sql
  - past_games_summary_by_team: ncaaf/past_games_summary_by_team.sql
---

# Predictions

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

## Future Predictions

_Home field advantage has not been included in these predictions. Historically, NCAA Football teams win 57.5% of their games at home._

<DataTable
    data={future_games}
    title='Predictions'
    rows=25
    rowShading="true" 
    rowLine="false"
    search="true">
    <Column id="visitor"/>
    <Column id="visitor_ELO"/>
    <Column id="home"/>
    <Column id="home_ELO"/>
    <Column id="home_win_pct1"/>
    <Column id="odds" align="right"/>
</DataTable>
