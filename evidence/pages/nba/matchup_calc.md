---
queries:
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

```sql teams_alpha_sort
    SELECT
        team
    FROM ${summary_by_team}
    ORDER BY team 
```


```predictions_table
    WITH cte_visitor_elo AS (
        SELECT
            'Away Elo Rating' as type,
            game_id,
            visitor_ELO as value,
            1 as key
        FROM ${filtered_future_games}
    ),
    cte_home_elo AS (
        SELECT
            'Home Elo Rating',
            game_id,
            home_ELO,
            2
        FROM ${filtered_future_games}
    ),
    cte_elo_diff AS (
        SELECT
            'Elo Difference',
            game_id,
            elo_diff,
            3
        FROM ${filtered_future_games}
    ),
    cte_hfa AS (
        SELECT
            'Home Court Advantage',
            game_id,
            100 as hfa,
            4
        FROM ${filtered_future_games}
    ),
    cte_elo_diff_hfa AS (
        SELECT
            'Total Difference',
            game_id,
            elo_diff_hfa,
            5
        FROM ${filtered_future_games}
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
    select Type, Value, Key from cte_unions
    GROUP BY ALL
    ORDER BY key
```

```sql filtered_future_games
    select *
    from ${future_games}
    where home = '${inputs.home_team_dd.value}'
        AND visitor = '${inputs.away_team_dd.value}'
```

# Experimental: Matchup Calculator

This uses DuckDB WASM to calculate matchups "on the fly."
It is experimental and can both break in unexpected ways and return incorrect information.

<Dropdown
    data={teams_alpha_sort} 
    name=home_team_dd
    value=team
    title="Select Home Team"
>
    <DropdownOption valueLabel="None" value=" " />
</Dropdown>

<Dropdown
    data={teams_alpha_sort} 
    name=away_team_dd
    value=team
    title="Select Away Team"
>
    <DropdownOption valueLabel="None" value=" " />
</Dropdown>

{#if inputs.away_team_dd.value != " " && inputs.home_team_dd.value != " "}


# <Value data={filtered_future_games} column=visitor/> @ <Value data={filtered_future_games} column=home/>

<center>

### Team Matchup

_<Value data={summary_by_team.filter(st => st.team === inputs.away_team_dd.value)}  column=team/> (<Value data={summary_by_team.filter(st =>
        st.team === inputs.away_team_dd.value)} column=record/>) | elo <Value data={summary_by_team.filter(st => st.team === inputs.away_team_dd.value)}
        column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        st.team === inputs.away_team_dd.value)}  column=elo_rank/>_ <br> _<Value data={season_stats.filter(st =>
        st.team === inputs.away_team_dd.value)}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        st.team === inputs.away_team_dd.value)}  column=avg_margin_num1/> avg. margin_<br>
_<Value data={summary_by_team.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=team/> (<Value data={summary_by_team.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=record/>) | elo <Value data={summary_by_team.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=elo_rating/> | Rk: <Value data={summary_by_team.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=elo_rank/>_ <br> _<Value data={season_stats.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=points_for_num1/> ppg |  <Value data={season_stats.filter(st =>
        st.team === inputs.home_team_dd.value)}  column=avg_margin_num1/> avg. margin_

</center>

## Prediction Details

<DataTable data={predictions_table} rows=5  rowLines=false>
  <Column id=type/>
  <Column id=value/>
</DataTable>

Diff. of <Value data={filtered_future_games} column=elo_diff_hfa/> **->** <Value data={filtered_future_games} column=home_win_pct1/> Win Prob **->** <Value data={filtered_future_games} column=american_odds/> ML <br> <Value data={filtered_future_games} column=implied_line_num1/> Spread **->** Score: <Value data={filtered_future_games} column=predicted_score/> 

<script>

    $: test_val = Math.min(
            ...game_trend.filter(gt => (inputs.home_team_dd.value == gt.team || inputs.away_team_dd.value == gt.team)
            ).map(item => item.elo_rating)
        )

</script>

<LineChart
    data={game_trend.filter(gt => (inputs.home_team_dd.value == gt.team || inputs.away_team_dd.value == gt.team))} 
    x=date
    y=elo_post
    title='elo change over time'
    series=team
    yMin={parseFloat(test_val)-25}
    handleMissing=connect
    colorPalette={
        [
        '#29BDAD',
        '#DE4500'
        ]
    }
/>

## Last 5 Games - <Value data={summary_by_team.filter(st => st.team == inputs.away_team_dd.value)}  column=team/>

<DataTable
    data={most_recent_games.filter(rg => (inputs.away_team_dd.value == rg.visiting_team || inputs.away_team_dd.value == rg.home_team ))} 
    rows=5>
  <Column id=matchup/>
  <Column id=T title=" "/>
  <Column id=winning_team/>
  <Column id=score/>
  <Column id=elo_change_num1/>
</DataTable>

## Last 5 Games - <Value data={summary_by_team.filter(st => st.team ==inputs.home_team_dd.value)}  column=team/>

<DataTable
    data={most_recent_games.filter(rg => (inputs.home_team_dd.value == rg.visiting_team || inputs.home_team_dd.value == rg.home_team ))}  
    rows=5>
  <Column id=matchup/>
  <Column id=T title=" "/>
  <Column id=winning_team/>
  <Column id=score/>
  <Column id=elo_change_num1/>
</DataTable>

{/if}