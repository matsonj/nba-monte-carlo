---
sources:
  - future_games: nba/future_games.sql
  - game_trend: nba/game_trend.sql
---

# Detailed Analysis for Game <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=game_id/>

## insert date: <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=visitor/> @ <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=home/>

## trying to see if we can access game_trend from future_games and page params
<Value data={game_trend.filter(gt =>
    future_games.some(fg=>
        fg.game_id === parseInt($page.params.nba_games, 10) && fg.home == gt.team)
    )
} column=team/>

<LineChart
    data={game_trend.filter(gt =>
    future_games.some(fg=>
        fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == gt.team || fg.visitor == gt.team))
    )} 
    x=date
    y=elo_rating
    title='elo change over time'
    series=team
    step=true
    handleMissing=connect
    yMin=1400
/>
