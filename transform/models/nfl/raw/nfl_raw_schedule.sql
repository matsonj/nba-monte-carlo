{{
    config(
        materialized='external',
        location="../data/data_catalog/prep/{{this.name}}.parquet"
    )
}}


SELECT *
FROM {{ source( 'nfl', 'nfl_schedule' ) }}
