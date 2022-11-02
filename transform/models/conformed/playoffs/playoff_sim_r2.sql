{{
    config(
        materialized = "table",
        schema = "export"
) }}

WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r2','playoff_sim_r1' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}