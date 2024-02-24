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
    where season = '${inputs.team1_season}'
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
    where season = '${inputs.team2_season}'
    group by all
    order by team
```

<Dropdown
    data={seasons} 
    name=team1_season
    value=season
    title="Team 1 Year"
>
    <DropdownOption valueLabel="1986" value="1986" />
</Dropdown>

<Dropdown
    data={team1} 
    name=team1
    value=team
    title="Team 1"
>
    <DropdownOption valueLabel="BOS" value="BOS" />
</Dropdown>

<Dropdown
    data={seasons} 
    name=team2_season
    value=season
    title="Team 2 Year"
>
    <DropdownOption valueLabel="1996" value="1996" />
</Dropdown>

<Dropdown
    data={team2} 
    name=team2
    value=team
    title="Team 2"
>
    <DropdownOption valueLabel="CHI" value="CHI" />
</Dropdown>

```sql team1_history
    select * from nba_elo_history.nba_elo
    where season = '${inputs.team1_season}'
       and ( team1 = '${inputs.team1}' OR team2 = '${inputs.team1}')
    order by date
```

```sql team2_history
    select * from nba_elo_history.nba_elo
    where season = '${inputs.team2_season}'
        and ( team1 = '${inputs.team2}' OR team2 = '${inputs.team2}')
    order by date
```

{#if inputs.team1 !== ' ' && inputs.team1_season !== ' ' && inputs.team2 !== ' ' & inputs.team2_season !== ''}

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
            case when team1 = '${inputs.team1}' then elo1_pre else elo2_pre end as elo,
            case when team1 = '${inputs.team1}' then score1 else score2 end as pf,
            case when team1 = '${inputs.team1}' then score2 else score1 end as pa,
            '${inputs.team1}' || ':' || '${inputs.team1_season}' as key,
        from ${elo_history  } where (team1 = '${inputs.team1}' OR team2 = '${inputs.team1}') AND season = '${inputs.team1_season}'
    )
    select 
        key, 
        count(*) as ct,
        count(*) filter (where winner = '${inputs.team1}' and playoff = 'r') as wins,
        -count(*) filter (where loser = '${inputs.team1}' and playoff = 'r') as losses,
        count(*) filter (where winner = '${inputs.team1}' and team1 = '${inputs.team1}' and playoff = 'r') as home_wins,
        -count(*) filter (where loser = '${inputs.team1}' and team1 = '${inputs.team1}' and playoff = 'r') as home_losses,
        count(*) filter (where winner = '${inputs.team1}' and team2 = '${inputs.team1}' and playoff = 'r') as away_wins,
        -count(*) filter (where loser = '${inputs.team1}' and team2 = '${inputs.team1}' and playoff = 'r') as away_losses,
        count(*) filter (where winner = '${inputs.team1}' and playoff <> 'r') as playoff_wins,
        -count(*) filter (where loser = '${inputs.team1}' and playoff <> 'r') as playoff_losses,
        avg(pf) as pf,
        avg(-pa) as pa,
        avg(pf) - avg(pa) as margin,
        min(elo) as min_elo,
        avg(elo) as avg_elo,
        max(elo) as max_elo,
        '${inputs.team1}' as team,
        '${inputs.team1_season}' as season
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
            case when team1 = '${inputs.team2}' then elo1_pre else elo2_pre end as elo,
            case when team1 = '${inputs.team2}' then score1 else score2 end as pf,
            case when team1 = '${inputs.team2}' then score2 else score1 end as pa,
            '${inputs.team2}' || ':' || '${inputs.team2_season}' as key,
        from ${elo_history  } where (team1 = '${inputs.team2}' OR team2 = '${inputs.team2}') AND season = '${inputs.team2_season}'
    )
    select 
        key, 
        count(*) as ct,
        count(*) filter (where winner = '${inputs.team2}' and playoff = 'r') as wins,
        -count(*) filter (where loser = '${inputs.team2}' and playoff = 'r') as losses,
        count(*) filter (where winner = '${inputs.team2}' and team1 = '${inputs.team2}' and playoff = 'r') as home_wins,
        -count(*) filter (where loser = '${inputs.team2}' and team1 = '${inputs.team2}' and playoff = 'r') as home_losses,
        count(*) filter (where winner = '${inputs.team2}' and team2 = '${inputs.team2}' and playoff = 'r') as away_wins,
        -count(*) filter (where loser = '${inputs.team2}' and team2 = '${inputs.team2}' and playoff = 'r') as away_losses,
        count(*) filter (where winner = '${inputs.team2}' and playoff <> 'r') as playoff_wins,
        -count(*) filter (where loser = '${inputs.team2}' and playoff <> 'r') as playoff_losses,
        avg(pf) as pf,
        avg(-pa) as pa,
        avg(pf) - avg(pa) as margin,
        min(elo) as min_elo,
        avg(elo) as avg_elo,
        max(elo) as max_elo,
        '${inputs.team2}' as team,
        '${inputs.team2_season}' as season
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
    left join cte_unpivot u1 on u1.stat = s.stat and u1.key = '${inputs.team1}' || ':' || '${inputs.team1_season}'
    left join cte_unpivot u2 on u2.stat = s.stat and u2.key = '${inputs.team2}' || ':' || '${inputs.team2_season}'
```
{/if}

## Head to Head Stats

<DataTable data={stat_table} rows=all>
    <Column id="t1" align="center" title=" " />
    <Column id="team1" align="right" title="{inputs.team1_season} {inputs.team1}"/>
    <Column id="stat" align="center" title="category" />
    <Column id="team2" align="left" title="{inputs.team2_season} {inputs.team2}"/>
    <Column id="t2" align="center" title=" " />
</DataTable>

## Elo Trends

```sql team1_trend
    with cte_games AS (
        select 
            date,
            case when team1 = '${inputs.team1}' then elo1_post else elo2_post end as elo,
            '${inputs.team1}' || ':' || '${inputs.team1_season}' as key,
        from ${elo_history  } where (team1 = '${inputs.team1}' OR team2 = '${inputs.team1}') AND season = '${inputs.team1_season}'
    )
    select 
        key, 
        date,
        elo,
        '${inputs.team1_season}' || ' ' || '${inputs.team1}' as team,
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
        '${inputs.team2_season}' || ' ' || '${inputs.team2}' as team,
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