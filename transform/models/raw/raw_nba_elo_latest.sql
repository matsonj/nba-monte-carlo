{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'s3://datalake/psa/nba_elo_latest/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'nba_elo_latest' ) }}