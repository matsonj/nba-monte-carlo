---
queries:
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

<Accordion>
  <AccordionItem title="Detailed Results by Team">
    <DataTable
        data={past_games_summary_by_team}
        title='Prediction Accuracy by Team'
        rows=30
    />
  </AccordionItem>
</Accordion>
