{{
    config(
        materialized='external',
        location="../data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT 
    column00 as id,
    column01 as type,
    column03 as "date",
    column05 as "Start (ET)",
    column06 as "VisTm",
    column08 as "HomeTm",
    column10 as "Attend.",
    column11 as arena,
    column12 as notes,
    column13 as series_id
FROM {{ source( 'nba', 'nba_schedule' ) }}
