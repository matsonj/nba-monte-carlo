-- model name: nfl_playoff_sim_r2
-- Divisional round using reseeded teams
with
    reseed as (
        select 
            scenario_id, 
            substring(seed,1,3) || '-' || ROW_NUMBER() OVER (PARTITION BY scenario_id, substring(seed,1,3) ORDER BY seed) as reseed_value,
            winning_team as team
        from {{ ref('nfl_playoff_sim_r3') }}
    ),
    cte as (
        select
            r.scenario_id,
            s.game_id,
            s.week_number as series_id,
            s.visiting_team as visitor_key,
            s.home_team as home_key,
            ev.team as visiting_team,
            eh.team as home_team,
            evr.elo_rating as visiting_team_elo_rating,
            ehr.elo_rating as home_team_elo_rating,
            {{ elo_calc('EHR.elo_rating', 'EVR.elo_rating', var('nfl_elo_offset')) }} as home_team_win_probability,
            r.rand_result,
            case
                when {{ elo_calc('EHR.elo_rating', 'EVR.elo_rating', var('nfl_elo_offset')) }} >= r.rand_result then eh.team
                else ev.team
            end as winning_team
        from {{ ref('nfl_schedules') }} s
        left join {{ ref('nfl_random_num_gen') }} r on r.game_id = s.game_id
        left join reseed eh on eh.reseed_value = s.home_team and eh.scenario_id = r.scenario_id
        left join reseed ev on ev.reseed_value = s.visiting_team and ev.scenario_id = r.scenario_id
        left join {{ ref('nfl_initialize_seeding') }} ehr on ehr.seed = s.home_team and ehr.scenario_id = r.scenario_id
        left join {{ ref('nfl_initialize_seeding') }} evr on evr.seed = s.visiting_team and evr.scenario_id = r.scenario_id
        where s.type = 'playoffs_r4'
    )

select
    cte.scenario_id,
    cte.series_id,
    cte.game_id,
    cte.winning_team,
    case when cte.winning_team = cte.home_team then cte.home_team_elo_rating else cte.visiting_team_elo_rating end as elo_rating,
    case when cte.winning_team = cte.home_team then cte.home_key else cte.visitor_key end as seed,
    {{ var('sim_start_game_id') }} as sim_start_game_id
from cte


