---
sources:
  - future_games: nba/future_games.sql
  - game_trend: nba/game_trend.sql
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
  - past_games: nba/past_games.sql
  - most_recent_games: nba/most_recent_games.sql
---

```season_stats
with cte_home AS (
    SELECT 
        game_id,
        home_team AS team,
        actual_home_team_score as score,
        actual_home_team_score - actual_visiting_team_score  as margin
    FROM ${past_games}
),
cte_visitor AS (
    SELECT 
        game_id,
        visiting_team AS team,
        actual_visiting_team_score as score,
        actual_visiting_team_score - actual_home_team_score as margin
    FROM ${past_games}
),
cte_union AS (
    SELECT * FROM cte_home
    UNION ALL
    SELECT * FROM cte_visitor
)
SELECT
    team,
    COUNT(*) AS games_played,
    AVG(score::real) AS points_for_num1,
    AVG(margin) AS avg_margin_num1
FROM cte_union
GROUP BY ALL
```

# Detailed Analysis for Game <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=game_id/>

## Game Date <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=date/>

**Away: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=team/> (<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=record/>)** | <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=elo_rank/> | <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=avg_margin_num1/> avg. margin<br>
** Home: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=team/> (<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=record/>)** | <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=elo_rank/> | <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team))
    )}  column=avg_margin_num1/> avg. margin

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
    yMin={Math.min(
        game_trend.filter(gt =>
            future_games.some(fg=>
                fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == gt.team || fg.visitor == gt.team))
        ).map(item => item.elo_rating)
    )}
/>

## Last 5 Games - <Value data={summary_by_team.filter(st => future_games.some(fg => fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == st.team)))}  column=team/>

<DataTable
    data={most_recent_games.filter(rg =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.visitor == rg.visiting_team || fg.visitor == rg.home_team ))
    )} 
    rows=5>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visiting_team/>
  <Column id=" "/>
  <Column id=home_team/>
  <Column id=winning_team/>
  <Column id=score/>
</DataTable>

## Last 5 Games - <Value data={summary_by_team.filter(st => future_games.some(fg => fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == st.team)))}  column=team/>

<DataTable
    data={most_recent_games.filter(rg =>
        future_games.some(fg=>
            fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == rg.visiting_team || fg.home == rg.home_team ))
    )} 
    rows=5>
  <Column id=date/>
  <Column id=T title=" "/>
  <Column id=visiting_team/>
  <Column id=" "/>
  <Column id=home_team/>
  <Column id=winning_team/>
  <Column id=score/>
</DataTable>

## Prediction Breakdown

**Away Elo Rating:** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=visitor_ELO/><br>
**Home Elo Rating:** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=home_ELO/><br>
**Elo Difference:** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=elo_diff/><br>
**Home Field Advantage:** 70<br>
**Total Difference:** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=elo_diff_hfa/><br>

Elo difference of <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=elo_diff_hfa/> **->** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=home_win_pct1/> Home Win Pct **->** <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=implied_line_num1/> game line **->** Score: <Value data={future_games.filter(d => d.game_id === parseInt($page.params.nba_games, 10))} column=predicted_score/> 
