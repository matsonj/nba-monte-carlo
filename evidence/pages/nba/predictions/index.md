---
queries:
  - future_games: nba/future_games.sql
  - past_games: nba/past_games.sql
  - past_games_summary: nba/past_games_summary.sql
  - past_games_summary_by_team: nba/past_games_summary_by_team.sql
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

<Accordion>
  <AccordionItem title="Detailed Results by Team">
    <DataTable
        data={past_games_summary_by_team}
        title='Prediction Accuracy by Team'
        rows=30
    />
  </AccordionItem>
</Accordion>



## Future Predictions

_Historically, NBA teams win 62% of their games at home, which explains why teams with lower elo ratings can be predicted to win._


<DataTable data={future_games} rows=15 link=game_link search=true>
  <Column id=game_id/>
  <Column id=T title=" "/>
  <Column id=visitor/>
  <Column id=visitor_ELO title="Elo Rtg"/>
  <Column id=home/>
  <Column id=home_ELO title="Elo Rtg"/>
  <Column id=home_win_pct1 title="Win % (Home)"/>
  <Column id=american_odds align=right title="Odds (Home)"/>
  <Column id=implied_line_num1 title="Line (Home)"/>
  <Column id=predicted_score title="Score"/>
</DataTable>