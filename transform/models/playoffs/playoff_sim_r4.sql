{{
  config(
    materialized = "view",
    post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}

-- depends-on: {{ ref( 'playoff_sim_r3' ) }}

WITH cte_playoff_sim AS (
{{ playoff_sim('playoffs_r4','/tmp/storage/playoff_sim_r3.parquet','parquet') }}
)

{{ playoff_sim_end( 'cte_playoff_sim', 'ref' ) }}