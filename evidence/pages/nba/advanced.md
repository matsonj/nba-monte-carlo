---
queries:
  - seed_details: nba/seed_details.sql
title: Experimental Views
sidebar_position: 99
---

# Advanced Analytical views 

This is experimental and may break at any time

```seed_details_cdf
WITH 
cte_seeds AS (
    SELECT DISTINCT seed
    FROM ${seed_details}
    UNION ALL
    SELECT 0 AS seed
),
cte_teams AS(
    SELECT DISTINCT team, conf, S.seed
    FROM ${seed_details} SD
    LEFT JOIN cte_seeds S ON 1=1
),
cte_interim_calc AS (
SELECT 
    T.team, 
    T.seed, 
    T.conf, 
    COALESCE(SD.occurances_pct1,0) AS occurances_pct1
FROM cte_teams T
LEFT JOIN ${seed_details} SD ON T.team = SD.team AND T.seed = SD.seed
)
SELECT *, SUM(occurances_pct1) OVER (PARTITION BY team ORDER BY seed) AS cumulative_pct1
FROM cte_interim_calc
ORDER BY seed, cumulative_pct1
```

```seed_details_cdf_scatter
SELECT * FROM ${seed_details_cdf}
WHERE cumulative_pct1 > 0.005 AND cumulative_pct1 < 0.995
```

```sql wins_by_seed
    SELECT
        avg(wins) as avg_wins,
        conf,
        ' '||round(season_rank,0)::int as seed,
        count(*) as occurances,
        round(
            percentile_cont(0.05) within group (order by wins asc), 1
        ) as wins_5th,
        round(
            percentile_cont(0.95) within group (order by wins asc), 1
        ) as wins_95th,
        min(wins) as min_wins,
        max(wins) as max_wins,
        season_rank as seed_rank
    FROM src_reg_season_end
    GROUP BY ALL
    order by seed_rank, conf desc
```
<BoxPlot 
    data={wins_by_seed.filter(d => d.conf === "East")}
    name=seed
    min=min_wins
    max=max_wins
    intervalBottom=wins_5th
    midpoint=avg_wins
    intervalTop=wins_95th
    yFmt=num0
    title="Wins by Seed, Eastern Conference"
    swapXY=true
    xTitle="Wins"
    >
    <ReferenceLine y=42 label='.500 line' hideValue=true lineColor='#3b4856' labelColor='#3b4856'/>
</BoxPlot>

<BoxPlot 
    data={wins_by_seed.filter(d => d.conf === "West")}
    name=seed
    min=min_wins
    max=max_wins
    intervalBottom=wins_5th
    midpoint=avg_wins
    intervalTop=wins_95th
    yFmt=num0
    title="Wins by Seed, Western Conference"
    swapXY=true
    xTitle="Wins"
    >
    <ReferenceLine y=42 label='.500 line' hideValue=true lineColor='#3b4856' labelColor='#3b4856'/>
</BoxPlot>

<LineChart 
    data={seed_details_cdf.filter(d => d.conf === "East")}  
    x=seed 
    y=cumulative_pct1
    series=team
    title='Eastern Conference'
    xAxisTitle=seed
    xTickMarks=true
    yMax=1
/>

<LineChart 
    data={seed_details_cdf.filter(d => d.conf === "West")}  
    x=seed 
    y=cumulative_pct1
    series=team
    title='Western Conference'
    xAxisTitle=seed
    xTickMarks=true
    yMax=1
/>

{#if seed_details_cdf_scatter.length > 0}
<ScatterPlot 
    data={seed_details_cdf_scatter.filter(d => d.conf === "East")}  
    x=seed 
    y=cumulative_pct1
    series=team
    title='Eastern Conference'
    xAxisTitle=seed
    xTickMarks=true
    yMax=1
    yMin=0
/>

<ScatterPlot 
    data={seed_details_cdf_scatter.filter(d => d.conf === "West")}  
    x=seed 
    y=cumulative_pct1
    series=team
    title='Western Conference'
    xAxisTitle=seed
    xTickMarks=true
    yMax=1
    yMin=0
/>
{/if}