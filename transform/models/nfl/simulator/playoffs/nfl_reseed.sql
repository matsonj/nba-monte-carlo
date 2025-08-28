with cte_reseed as (
select scenario_id,
  winning_team,
  seed,
  substring(seed,1,3) as conf,
  sim_start_game_id
from {{ ref('nfl_playoff_sim_r1') }}
union all
select
  scenario_id,
  winning_team,
  seed,
  conf,
  sim_start_game_id
from {{ ref('nfl_initialize_seeding') }}
where seed IN ('AFC-1','NFC-1')
order by scenario_id, seed
)
select *,
conf || '-' || ROW_NUMBER() OVER (PARTITION BY scenario_id, Conf ORDER BY seed) as reseed_value
from cte_reseed
order by scenario_id, seed