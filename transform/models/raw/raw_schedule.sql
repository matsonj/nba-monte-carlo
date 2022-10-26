{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'schedule' ) }}