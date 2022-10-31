{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'s3://datalake/psa/xf_series_to_seed/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'xf_series_to_seed' ) }}