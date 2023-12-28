WITH cte_playoff_sim AS (
    {{ playoff_sim('playoffs_r3','playoff_sim_r2' ) }}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}
