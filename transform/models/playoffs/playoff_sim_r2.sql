{{
  config(
    materialized = "view",
    post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}

-- depends-on: {{ ref( 'playoff_sim_r1' ) }}

WITH cte_playoff_sim AS (
{{ playoff_sim('playoffs_r2','/tmp/storage/playoff_sim_r1.parquet','parquet') }}
)

{{ playoff_sim_end( 'cte_playoff_sim', 'ref' ) }}