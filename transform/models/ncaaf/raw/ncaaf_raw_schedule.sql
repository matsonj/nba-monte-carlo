{{
    config(
        materialized='external',
        location="../data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT *
FROM {{ source( 'ncaaf', 'ncaaf_schedule' ) }}
