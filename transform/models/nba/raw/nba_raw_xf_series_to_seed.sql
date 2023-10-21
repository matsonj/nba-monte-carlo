{{
    config(
        materialized='external',
        location="../data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT *
FROM {{ source( 'nba', 'xf_series_to_seed' ) }}
GROUP BY ALL
