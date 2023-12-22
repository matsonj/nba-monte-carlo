SELECT
    *,
    elo_vs_vegas*-1 as elo_vs_vegas_num1,
    '/ncaaf/conferences/' || conf as team_link
FROM src_ncaaf_reg_season_summary_by_conf
ORDER BY avg_elo_rating DESC