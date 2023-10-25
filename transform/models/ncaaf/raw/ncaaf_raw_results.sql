{{
    config(
        materialized='external',
        location="{{ env_var('MELTANO_PROJECT_ROOT') }}/data/data_catalog/raw/{{this.name}}.parquet"
    )
}}

SELECT wk,
    regexp_replace("winner", '^\(([1-9]|1[0-9]|2[0-5])\) ', '') as winner,
    winner_pts,
    regexp_replace("loser", '^\(([1-9]|1[0-9]|2[0-5])\) ', '') as loser,
    loser_pts
FROM {{ source( 'ncaaf', 'ncaaf_results' ) }}
