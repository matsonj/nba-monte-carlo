{{
    config(
        materialized='external',
        location="{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT *
FROM {{ source( 'nba', 'xf_series_to_seed' ) }}
GROUP BY ALL
