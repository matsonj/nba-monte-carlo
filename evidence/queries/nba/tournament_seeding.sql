WITH cte_final_seeds AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY Scenario_id, conf 
            ORDER BY conf, made_wildcard, wins desc, pt_diff desc, random()) AS final_seed,
        *
    FROM src_tournament_end
    WHERE (made_tournament = 1 OR made_wildcard = 1)
),
cte_agg AS (
    SELECT
        winning_team as team,
        conf,
        final_seed,
        COUNT(*) / 10000.0 as occurances
    FROM cte_final_seeds
    GROUP BY ALL
    ORDER BY conf, final_seed, winning_team
)
SELECT
    team,
    conf,
    COALESCE(first(occurances) FILTER (WHERE final_seed = 1 ),0) AS "1_pct1",
    COALESCE(first(occurances) FILTER (WHERE final_seed = 2 ),0) AS "2_pct1",
    COALESCE(first(occurances) FILTER (WHERE final_seed = 3 ),0) AS "3_pct1",
    COALESCE(first(occurances) FILTER (WHERE final_seed = 4 ),0) AS "4_pct1",
    SUM(occurances) AS total_pct1
FROM cte_agg
GROUP BY ALL
ORDER BY "1_pct1" DESC, ("1_pct1"+"2_pct1") DESC, ("1_pct1"+"2_pct1"+"3_pct1") DESC, ("1_pct1"+"2_pct1"+"3_pct1"+"4_pct1") DESC