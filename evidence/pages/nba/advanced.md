---
queries:
  - seed_details: nba/seed_details.sql
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