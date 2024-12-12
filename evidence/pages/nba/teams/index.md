---
queries:
  - reg_season: nba/reg_season.sql
  - standings: nba/standings.sql
  - summary_by_team: nba/summary_by_team.sql
title: Teams
sidebar_position: 2
---

# Team Browser
## Select a conference

```sql wins_array
    with
        cte_bounds as (
            select min(wins) as min_wins, max(wins) as max_wins from src_reg_season_end
        ),
        cte_series as (
            select generate_series as i
            from
                generate_series(
                  --  (select min_wins from cte_bounds), (select max_wins from cte_bounds)
                  10,72
                )
        ),
        cte_teams as (select i as wins, team from cte_series, src_nba_teams),
        cte_wins_array as (
            select t.team, t.wins as wins, count(*) / 10000.0 as odds
            from cte_teams t
            left join src_reg_season_end e on e.wins = t.wins and t.team = e.winning_team
            group by all
        )
    select team, array_agg({'wins':date_add(DATE '2024-01-01',wins::int), 'odds':odds}) as wins_array
    from cte_wins_array
    group by team
```


```sql filtered_summary_by_team
    select st.*, wa.wins_array
    from ${summary_by_team} st
    left join ${wins_array} wa on wa.team = st.team
    where conf like '${inputs.conference}'
    order by avg_wins desc
```



<ButtonGroup
    data={summary_by_team} 
    name=conference
    value=conf
>
    <ButtonGroupItem valueLabel="All" value="%" default />
</ButtonGroup>

{#if inputs.conference != 'null'}

<DataTable data={filtered_summary_by_team} link=team_link wrapTitles=true rows=30>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record title = "Record (W-L)"/>
  <Column id=elo_rating/>
  <Column id=avg_wins title="Avg. Wins"/>
  <Column id=wins_array contentType=sparkarea title="Win Range" sparkX=wins sparkY=odds sparkWidth=65 />
  <Column id=elo_vs_vegas_num1 contentType=delta title="Elo vs. Vegas"/>
  <Column id=make_playoffs_pct1 title="Make Playoffs (%)"/>
  <Column id=win_finals_pct1 title = "Win Finals (%)" />
</DataTable>

{:else }

<DataTable data={summary_by_team} link=team_link rows=30>
  <Column id=seed/>
  <Column id=" " contentType=image height=25px/>
  <Column id=team/>
  <Column id=record/>
  <Column id=elo_rating/>
  <Column id=avg_wins/>
  <Column id=elo_vs_vegas_num1 contentType=delta/>
  <Column id=make_playoffs_pct1/>
  <Column id=win_finals_pct1/>
</DataTable>

{/if}

