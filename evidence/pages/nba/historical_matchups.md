# Historical Matchups
Ever wondered if the '86 Celtics could beat the '96 Bulls? Wonder no more!

```sql elo_history
    select *
    from nba_elo_history.nba_elo
```

```sql seasons
    select season
    from ${elo_history}
    group by all
    order by season
```

```sql team1
    select * from (
        select season, team1 as team
        from ${elo_history}
        union all
        select season, team2
        from ${elo_history} )
    where season = '${inputs.team1_season_dd.value}'
    group by all
    order by team
```

```sql team2
    select * from (
        select season, team1 as team
        from ${elo_history}
        union all
        select season, team2
        from ${elo_history} )
    where season = '${inputs.team2_season_dd.value}'
    group by all
    order by team
```

<Dropdown
    data={seasons} 
    name=team1_season_dd
    value=season
    title="Team 1 Year"
>
    <DropdownOption valueLabel="1986" value="1986" />
</Dropdown>

<Dropdown
    data={team1} 
    name=team1_dd
    value=team
    title="Team 1"
>
    <DropdownOption valueLabel="BOS" value="BOS" />
</Dropdown>

<Dropdown
    data={seasons} 
    name=team2_season_dd
    value=season
    title="Team 2 Year"
>
    <DropdownOption valueLabel="1996" value="1996" />
</Dropdown>

<Dropdown
    data={team2} 
    name=team2_dd
    value=team
    title="Team 2"
>
    <DropdownOption valueLabel="CHI" value="CHI" />
</Dropdown>

```sql team1_history
    select * from nba_elo_history.nba_elo
    where season = '${inputs.team1_season_dd.value}'
       and ( team1 = '${inputs.team1_dd.value}' OR team2 = '${inputs.team1_dd.value}')
    order by date
```

```sql team2_history
    select * from nba_elo_history.nba_elo
    where season = '${inputs.team2_season_dd.value}'
        and ( team1 = '${inputs.team2_dd.value}' OR team2 = '${inputs.team2_dd.value}')
    order by date
```

```sql team1_stats
    with cte_games AS (
        select 
            team1, 
            team2,
            score1,
            score2,
            playoff,
            case when score1 > score2 then team1 else team2 end as winner,
            case when score1 < score2 then team1 else team2 end as loser,
            case when team1 = '${inputs.team1_dd.value}' then elo1_pre else elo2_pre end as elo,
            case when team1 = '${inputs.team1_dd.value}' then score1 else score2 end as pf,
            case when team1 = '${inputs.team1_dd.value}' then score2 else score1 end as pa,
            '${inputs.team1_dd.value}' || ':' || '${inputs.team1_season_dd.value}' as key,
        from ${elo_history  } where (team1 = '${inputs.team1_dd.value}' OR team2 = '${inputs.team1_dd.value}') AND season = '${inputs.team1_season_dd.value}'
    )
    select 
        key, 
        count(*) as ct,
        count(*) filter (where winner = '${inputs.team1_dd.value}' and playoff = 'r') as wins,
        -count(*) filter (where loser = '${inputs.team1_dd.value}' and playoff = 'r') as losses,
        count(*) filter (where winner = '${inputs.team1_dd.value}' and team1 = '${inputs.team1_dd.value}' and playoff = 'r') as home_wins,
        -count(*) filter (where loser = '${inputs.team1_dd.value}' and team1 = '${inputs.team1_dd.value}' and playoff = 'r') as home_losses,
        count(*) filter (where winner = '${inputs.team1_dd.value}' and team2 = '${inputs.team1_dd.value}' and playoff = 'r') as away_wins,
        -count(*) filter (where loser = '${inputs.team1_dd.value}' and team2 = '${inputs.team1_dd.value}' and playoff = 'r') as away_losses,
        count(*) filter (where winner = '${inputs.team1_dd.value}' and playoff <> 'r') as playoff_wins,
        -count(*) filter (where loser = '${inputs.team1_dd.value}' and playoff <> 'r') as playoff_losses,
        avg(pf) as pf,
        avg(-pa) as pa,
        avg(pf) - avg(pa) as margin,
        min(elo) as min_elo,
        avg(elo) as avg_elo,
        max(elo) as max_elo,
        '${inputs.team1_dd.value}' as team,
        '${inputs.team1_season_dd.value}' as season
    from cte_games
    GROUP BY ALL
```

```sql team2_stats
    with cte_games AS (
        select 
            team1, 
            team2,
            score1,
            score2,
            playoff,
            case when score1 > score2 then team1 else team2 end as winner,
            case when score1 < score2 then team1 else team2 end as loser,
            case when team1 = '${inputs.team2_dd.value}' then elo1_pre else elo2_pre end as elo,
            case when team1 = '${inputs.team2_dd.value}' then score1 else score2 end as pf,
            case when team1 = '${inputs.team2_dd.value}' then score2 else score1 end as pa,
            '${inputs.team2_dd.value}' || ':' || '${inputs.team2_season_dd.value}' as key,
        from ${elo_history  } where (team1 = '${inputs.team2_dd.value}' OR team2 = '${inputs.team2_dd.value}') AND season = '${inputs.team2_season_dd.value}'
    )
    select 
        key, 
        count(*) as ct,
        count(*) filter (where winner = '${inputs.team2_dd.value}' and playoff = 'r') as wins,
        -count(*) filter (where loser = '${inputs.team2_dd.value}' and playoff = 'r') as losses,
        count(*) filter (where winner = '${inputs.team2_dd.value}' and team1 = '${inputs.team2_dd.value}' and playoff = 'r') as home_wins,
        -count(*) filter (where loser = '${inputs.team2_dd.value}' and team1 = '${inputs.team2_dd.value}' and playoff = 'r') as home_losses,
        count(*) filter (where winner = '${inputs.team2_dd.value}' and team2 = '${inputs.team2_dd.value}' and playoff = 'r') as away_wins,
        -count(*) filter (where loser = '${inputs.team2_dd.value}' and team2 = '${inputs.team2_dd.value}' and playoff = 'r') as away_losses,
        count(*) filter (where winner = '${inputs.team2_dd.value}' and playoff <> 'r') as playoff_wins,
        -count(*) filter (where loser = '${inputs.team2_dd.value}' and playoff <> 'r') as playoff_losses,
        avg(pf) as pf,
        avg(-pa) as pa,
        avg(pf) - avg(pa) as margin,
        min(elo) as min_elo,
        avg(elo) as avg_elo,
        max(elo) as max_elo,
        '${inputs.team2_dd.value}' as team,
        '${inputs.team2_season_dd.value}' as season
    from cte_games
    GROUP BY ALL
```

```sql stat_table
    with cte_combined as (
        select * from ${team1_stats}
        union all
        select * from ${team2_stats}
    ),
    cte_unpivot as (
        UNPIVOT cte_combined
        ON COLUMNS(* EXCLUDE (key, ct, team, season))
        INTO
            NAME stat
            VALUE value
    ),
    cte_stats as (
        select distinct stat
        from cte_unpivot
    )
    select 
        CASE WHEN u1.value > u2.value THEN '✅' ELSE '' END AS "t1",
        abs(u1.value::int) as "team1",
        s.stat,
        abs(u2.value::int) as "team2",
        CASE WHEN u2.value > u1.value THEN '✅' ELSE '' END AS "t2"
    from cte_stats s
    left join cte_unpivot u1 on u1.stat = s.stat and u1.key = '${inputs.team1_dd.value}' || ':' || '${inputs.team1_season_dd.value}'
    left join cte_unpivot u2 on u2.stat = s.stat and u2.key = '${inputs.team2_dd.value}' || ':' || '${inputs.team2_season_dd.value}'
```

## Head to Head Stats

<DataTable data={stat_table} rows=all>
    <Column id="t1" align="center" title=" " />
    <Column id="team1" align="right" title="{inputs.team1_season_dd.value} {inputs.team1_dd.value}"/>
    <Column id="stat" align="center" title="category" />
    <Column id="team2" align="left" title="{inputs.team2_season_dd.value} {inputs.team2_dd.value}"/>
    <Column id="t2" align="center" title=" " />
</DataTable>

## Elo Trends

```sql team1_trend
    with cte_games AS (
        select 
            date,
            case when team1 = '${inputs.team1_dd.value}' then elo1_post else elo2_post end as elo,
            '${inputs.team1_dd.value}' || ':' || '${inputs.team1_season_dd.value}' as key,
        from ${elo_history  } where (team1 = '${inputs.team1_dd.value}' OR team2 = '${inputs.team1_dd.value}') AND season = '${inputs.team1_season_dd.value}'
    )
    select 
        key, 
        date,
        elo,
        '${inputs.team1_season_dd.value}' || ' ' || '${inputs.team1_dd.value}' as team,
        ROW_NUMBER() OVER (ORDER BY date) as game_id
    from cte_games
```

```sql team2_trend
    with cte_games AS (
        select 
            date,
            case when team1 = '${inputs.team2}' then elo1_post else elo2_post end as elo,
            '${inputs.team2}' || ':' || '${inputs.team2_season}' as key,
        from ${elo_history  } where (team1 = '${inputs.team2}' OR team2 = '${inputs.team2}') AND season = '${inputs.team2_season}'
    )
    select 
        key, 
        date,
        elo,
        '${inputs.team2_season_dd.value}' || ' ' || '${inputs.team2_dd.value}' as team,
        ROW_NUMBER() OVER (ORDER BY date) as game_id
    from cte_games
```

```sql combined_trend
    select * from ${team1_trend}
    union all
    select * from ${team2_trend}
```

<script>

$: y_min = Math.min(...combined_trend.map(item => item.elo))

</script>

<LineChart
    data={combined_trend} 
    x=game_id
    y=elo
    title='elo change over time'
    series=team
    yMin={parseFloat(y_min)-25}
    xAxisTitle='games played'
    handleMissing=connect
    colorPalette={
        [
        '#29BDAD',
        '#DE4500'
        ]
    }
/>

## 7 Games Series Results

This is a 10k iteration monte carlo sim, calculated in browser using DuckDB WASM.

```sql elo_by_team
    select 
        t2.season || ' ' || t2.team as team2,
        t2.avg_elo - ('${inputs.elo_slider}'::real/2) as elo2,
        t1.season || ' ' || t1.team as team1,
        t1.avg_elo + ('${inputs.elo_slider}'::real/2) as elo1
    from ${team2_stats} t2
    left join ${team1_stats} t1 ON 1=1
```

```sql games
    SELECT I.generate_series AS game_id
    FROM generate_series(1, 7 ) AS I
```


```sql monte_carlo_sim
    WITH cte_scenario_gen AS (
        SELECT I.generate_series AS scenario_id
        FROM generate_series(1, 10000 ) AS I
    ),
    cte_schedule as (
        SELECT
            i.scenario_id,
            G.game_id,
            S.*,
            (random() * 10000)::smallint AS rand_result
        FROM cte_scenario_gen AS i
        CROSS JOIN ${elo_by_team} AS S
        LEFT JOIN ${games} G ON 1=1
    ),
    cte_step_1 as (
        Select *,
            ( 1 - (1 / (10 ^ (-( elo2 - elo1 )::real/400)+1))) * 10000 as team1_win_probability,
            CASE 
                WHEN ( 1 - (1 / (10 ^ (-( elo2 - elo1 )::real/400)+1))) * 10000  >= rand_result THEN S.team1
                ELSE S.team2
            END AS winning_team,
        From cte_schedule S
    ),
    cte_step_2 AS (
        SELECT step1.*,
            ROW_NUMBER() OVER (PARTITION BY scenario_id, winning_team  ORDER BY scenario_id, game_id ) AS series_result
        FROM cte_step_1 step1
    )
    select * from cte_step_2
```

```sql monte_carlo_winners
    SELECT scenario_id,
        game_id
    FROM ${monte_carlo_sim}
    WHERE series_result = 4
```

```sql mc_final_results
with
    cte_summary as (
        SELECT step2.* 
        FROM ${monte_carlo_sim} step2
            LEFT JOIN ${monte_carlo_winners} F ON F.scenario_id = step2.scenario_id 
                AND step2.game_id = f.game_id
    )
    SELECT
        E.scenario_id,
        E.game_id,
        E.winning_team
    FROM cte_summary E
    where E.series_result = 4
```

```sql mc_summary
    select
        winning_team,
        game_id as games_played,
        case when game_id = 4 then '4-0'
            when game_id = 5 then '4-1'
            when game_id = 6 then '4-2'
            else '4-3'
        end as result,
        count(*) as occurances,
        count(*) / 10000.0 as occurances_pct1
    from ${mc_final_results}
    group by all
    order by result
```

<BarChart 
    data={mc_summary}
    x=winning_team
    y=occurances_pct1
    series=result
    xAxisTitle=games_played
    title='Outcome by Team'
    labels=true
    swapXY=true 
/>

<BarChart 
    data={mc_summary}
    x=result
    y=occurances_pct1
    series=winning_team
    xAxisTitle=games_played
    title='Outcomes by Series Result'
    type=grouped
    labels=true
    sort=false
    swapXY=true 
/>


<Accordion>
  <AccordionItem title="Elo Slider - for vibes-based adjustments of results">

    _If you don't like the current results, you can modify the elo inputs with this slider._

    ### Elo Slider

    <Slider
        name=elo_slider
        value=score
        current=0
        title="elo slider"
    />
    <br>
    The current value is {inputs.elo_slider}. 
  </AccordionItem>
</Accordion>
