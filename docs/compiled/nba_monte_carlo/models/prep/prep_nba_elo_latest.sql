SELECT *
FROM '/workspaces/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
QUALIFY
    ROW_NUMBER() OVER (PARTITION BY _smart_source_lineno ORDER BY _sdc_extracted_at DESC) = 1