{{
  config(
    materialized = "view",
    post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}

-- depends-on: {{ ref( 'initialize_seeding' ) }}

WITH cte_playoff_sim AS (
{{ playoff_sim('playoffs_r1','/tmp/storage/initialize_seeding.parquet','parquet') }}
)

{{ playoff_sim_end( 'cte_playoff_sim', 'ref' ) }}