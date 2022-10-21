{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    series_id,
    seed
FROM {{ "'/tmp/storage/raw_xf_series_to_seed/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'raw_xf_series_to_seed' ) }}
