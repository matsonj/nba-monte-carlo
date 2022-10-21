{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ "'/tmp/storage/nba_schedule_2023/*.parquet'" if target.name == 'parquet' 
    else source('nba', 'schedule' ) }}