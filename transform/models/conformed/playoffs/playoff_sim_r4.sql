{{ 
    config(
        materialized='external', 
        location="/tmp/data_catalog/conformed/" ~ this.name ~ ".parquet"
) }}

WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r4','playoff_sim_r3' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}