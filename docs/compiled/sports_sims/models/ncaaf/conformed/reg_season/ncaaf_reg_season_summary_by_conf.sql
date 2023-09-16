

    WITH cte_summary AS (
    SELECT
        winning_team AS team,
        E.conf,
        ROUND(AVG(wins),1) AS avg_wins,
        V.win_total AS vegas_wins,
        ROUND(AVG(V.win_total) - AVG(wins), 1) AS elo_vs_vegas,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_5th,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY wins ASC), 1) AS wins_95th,
        COUNT(*) FILTER (WHERE made_playoffs = 1 AND first_round_bye = 0) AS made_postseason,
        COUNT(*) FILTER (WHERE first_round_bye = 1) AS first_round_bye,
        ROUND(PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_5th,
        ROUND(AVG(season_rank), 1) AS avg_seed,
        ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY season_rank ASC), 1) AS seed_95th
    FROM "mdsbox"."main"."ncaaf_reg_season_end" E
    LEFT JOIN "mdsbox"."main"."ncaaf_vegas_wins" V ON V.team = E.winning_team
    GROUP BY ALL
    )

SELECT 
    C.conf,
    SUM(A.wins) || ' - ' || SUM(A.losses) AS record,
    SUM(C.avg_wins) AS tot_wins,
    SUM(C.vegas_wins) AS vegas_wins,
    AVG(R.elo_rating) AS avg_elo_rating,
    SUM(c.elo_vs_vegas) AS elo_vs_vegas,
    COUNT(*) as teams
FROM cte_summary C
LEFT JOIN "mdsbox"."main"."ncaaf_reg_season_actuals" A ON A.team = C.team
LEFT JOIN "mdsbox"."main"."ncaaf_ratings" R ON R.team = C.team
GROUP BY ALL