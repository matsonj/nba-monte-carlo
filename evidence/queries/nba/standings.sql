SELECT
    team,
    wins::int || '-' || losses::int AS record
FROM src_reg_season_actuals_enriched