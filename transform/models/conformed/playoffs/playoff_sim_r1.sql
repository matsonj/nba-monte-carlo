{{ 
    config(
        materialized='external', 
        location="/tmp/data_catalog/conformed/" ~ this.name ~ ".parquet"
) }}

WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r1','initialize_seeding' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}