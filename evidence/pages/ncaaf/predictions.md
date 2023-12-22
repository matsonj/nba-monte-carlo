---
queries:
  - future_games: ncaaf/future_games.sql
  - past_games: ncaaf/past_games.sql
  - past_games_summary: ncaaf/past_games_summary.sql
  - past_games_summary_by_team: ncaaf/past_games_summary_by_team.sql
---

# Predictions

## Future Predictions

_Historically, NCAA Football teams win 57.5% of their games at home, which explains why teams with lower elo ratings can be predicted to win._

<DataTable
    data={future_games}
    title='Predictions'
    rows=25
    rowShading="true" 
    rowLine="false"
    search="true">
    <Column id="visitor"/>
    <Column id="home"/>
    <Column id="home_win_pct2"/>
    <Column id="odds" align="right"/>
    <Column id="implied_line_num1" align="right"/>
</DataTable>

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

<Accordion>
  <AccordionItem title="Detailed Results by Team">
    <DataTable
        data={past_games_summary_by_team}
        title='Prediction Accuracy by Team'
        rows=30
    />
  </AccordionItem>
</Accordion>
