---
queries:
  - future_games: nba/future_games.sql
  - game_trend: nba/game_trend.sql
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
  - past_games: nba/past_games.sql
  - most_recent_games: nba/most_recent_games.sql
title: Prediction Details
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

```predictions_table
    WITH cte_visitor_elo AS (
        SELECT
            'Away Elo Rating' as type,
            game_id,
            visitor_ELO as value,
            1 as key
        FROM ${future_games}
    ),
    cte_home_elo AS (
        SELECT
            'Home Elo Rating',
            game_id,
            home_ELO,
            2
        FROM ${future_games}
    ),
    cte_elo_diff AS (
        SELECT
            'Elo Difference',
            game_id,
            elo_diff,
            3
        FROM ${future_games}
    ),
    cte_hfa AS (
        SELECT
            'Home Court Advantage',
            game_id,
            100 as hfa,
            4
        FROM ${future_games}
    ),
    cte_elo_diff_hfa AS (
        SELECT
            'Total Difference',
            game_id,
            elo_diff_hfa,
            5
        FROM ${future_games}
    ),
    cte_unions AS (
    SELECT * FROM cte_visitor_elo
    UNION ALL
    SELECT * FROM cte_home_elo
    UNION ALL
    SELECT * FROM cte_elo_diff
    UNION ALL
    SELECT * FROM cte_hfa
    UNION ALL
    SELECT * FROM cte_elo_diff_hfa
    )
    select Type, Value, Key, game_id from cte_unions
    GROUP BY ALL
    ORDER BY key
```

```sql filtered_future_games
    select *
    from ${future_games}
    where game_id = '${params.nba_games}'
```

# <Value data={filtered_future_games} column=visitor/> @ <Value data={filtered_future_games} column=home/>

<center>

## Game ID <Value data={filtered_future_games} column=game_id/> on <Value data={filtered_future_games} column=date/>

### Team Matchup

_<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=team/> (<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=record/>) | elo <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=elo_rank/>_ <br> _<Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team))
    )}  column=avg_margin_num1/> avg. margin_<br>
_<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=team/> (<Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=record/>) | elo <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=elo_rank/>_ <br> _<Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team))
    )}  column=avg_margin_num1/> avg. margin_

</center>

## Prediction Details

<DataTable data={predictions_table.filter(d => d.game_id === parseInt(params.nba_games, 10))} rows=5 rowLines=false>
  <Column id=type/>
  <Column id=value/>
</DataTable>

Diff. of <Value data={future_games.filter(d => d.game_id === parseInt(params.nba_games, 10))} column=elo_diff_hfa/> **->** <Value data={future_games.filter(d => d.game_id === parseInt(params.nba_games, 10))} column=home_win_pct1/> Win Prob **->** <Value data={future_games.filter(d => d.game_id === parseInt(params.nba_games, 10))} column=american_odds/> ML <br> <Value data={future_games.filter(d => d.game_id === parseInt(params.nba_games, 10))} column=implied_line_num1/> Spread **->** Score: <Value data={future_games.filter(d => d.game_id === parseInt(params.nba_games, 10))} column=predicted_score/> 

<script>

    $: test_val = Math.min(
            ...game_trend.filter(gt =>
                future_games.some(fg=>
                    fg.game_id === parseInt($page.params.nba_games, 10) && (fg.home == gt.team || fg.visitor == gt.team))
            ).map(item => item.elo_rating)
        )
    $: y_min = Math.min(1600,test_val)

</script>

<LineChart
    data={game_trend.filter(gt =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == gt.team || fg.visitor == gt.team))
    )} 
    x=date
    y=elo_post
    title='elo change over time'
    series=team
    yMin={parseFloat(y_min)-10}
    handleMissing=connect
    yGridlines=false
    colorPalette={
        [
        '#0777b3',
        '#bd4e35'
        ]
    }
>
  <ReferenceLine y=1600 label="league avg." hideValue=true labelPosition=aboveStart lineColor='#3b4856' labelColor='#3b4856' />
</LineChart>

## Last 5 Games - <Value data={summary_by_team.filter(st => future_games.some(fg => fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == st.team)))}  column=team/>

<DataTable
    data={most_recent_games.filter(rg =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.visitor == rg.visiting_team || fg.visitor == rg.home_team ))
    )} 
    rows=5>
  <Column id=matchup/>
  <Column id=T title=" "/>
  <Column id=winning_team/>
  <Column id=score/>
  <Column id=elo_change_num1 title="Elo Change"/>
</DataTable>

## Last 5 Games - <Value data={summary_by_team.filter(st => future_games.some(fg => fg.game_id === parseInt(params.nba_games, 10) && (fg.home == st.team)))}  column=team/>

<DataTable
    data={most_recent_games.filter(rg =>
        future_games.some(fg=>
            fg.game_id === parseInt(params.nba_games, 10) && (fg.home == rg.visiting_team || fg.home == rg.home_team ))
    )} 
    rows=5>
  <Column id=matchup/>
  <Column id=T title=" "/>
  <Column id=winning_team/>
  <Column id=score/>
  <Column id=elo_change_num1 title="Elo Change"/>
</DataTable>