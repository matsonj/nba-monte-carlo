{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO 's3://datalake/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

-- depends-on: {{ ref( 'initialize_seeding' ) }}

WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r1','s3://datalake/conformed/initialize_seeding.parquet') if target.name == 'parquet'
        else playoff_sim('playoffs_r1','initialize_seeding' )}}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}