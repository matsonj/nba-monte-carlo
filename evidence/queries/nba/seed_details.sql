SELECT
    winning_team as team,
    season_rank as seed,
    conf,
    count(*) / 10000.0 as occurances_pct1
FROM src_reg_season_end
GROUP BY ALL
ORDER BY seed, count(*) DESC