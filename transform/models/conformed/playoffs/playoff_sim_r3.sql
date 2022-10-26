{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/data_catalog/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

-- depends-on: {{ ref( 'playoff_sim_r2' ) }}

WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r3','/tmp/data_catalog/conformed/playoff_sim_r2.parquet') if target.name == 'parquet'
        else playoff_sim('playoffs_r3','playoff_sim_r2' )}}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}