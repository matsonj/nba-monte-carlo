```sql elo_history
    select *
    from src_nba_elo_history
```

# Lakers vs Clippers

How are things looking for the Lakers vs Clippers on a historical basis?

## Elo Trends

```sql team1_trend
    with cte_games AS (
        select 
            date,
            case when team1 = 'LAL' then elo1_pre else elo2_pre end as elo,
        from ${elo_history} where (team1 = 'LAL' OR team2 = 'LAL') 
    )
    select 
        date,
        elo,
        'LAL' as team
    from cte_games
```

```sql team2_trend
    with cte_games AS (
        select 
            date,
            case when team1 = 'LAC' then elo1_pre else elo2_pre end as elo,
        from ${elo_history} where (team1 = 'LAC' OR team2 = 'LAC') 
    )
    select 
        date,
        elo,
        'LAC' as team
    from cte_games
```

```sql combined_trend
    select * from ${team1_trend}
    where date > '1994-01-01' and date < '2006-01-01'
    union all
    select * from ${team2_trend}
    where date > '1994-01-01' and date < '2006-01-01'
```

<script>

$: y_min = Math.min(...combined_trend.map(item => item.elo))

</script>

<ScatterPlot
    data={combined_trend} 
    x=date
    y=elo
    title='ELO value over time'
    series=team
    xAxisTitle='date'
    handleMissing=connect
    yMin={parseFloat(y_min)-25}
    yMax=1900
    pointSize=4
>
    <ReferenceArea xMin='1996-11-03' xMax='2004-06-15' label="Kobe & Shaq Era" color=yellow/>
</ScatterPlot>

