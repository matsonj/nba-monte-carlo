-- model name: nfl_playoff_sim_r1
with
    cte_seed as (
        select * from {{ ref('nfl_initialize_seeding') }}
    ),
    cte_step_1 as (
        select
            r.scenario_id,
            s.game_id,
            s.week_number as series_id,
            s.visiting_team as visitor_key,
            s.home_team as home_key,
            ev.winning_team as visiting_team,
            ev.elo_rating as visiting_team_elo_rating,
            eh.winning_team as home_team,
            eh.elo_rating as home_team_elo_rating,
            {{ elo_calc('EH.elo_rating', 'EV.elo_rating', var('nfl_elo_offset')) }} as home_team_win_probability,
            r.rand_result,
            case
                when {{ elo_calc('EH.elo_rating', 'EV.elo_rating', var('nfl_elo_offset')) }} >= r.rand_result then eh.winning_team
                else ev.winning_team
            end as winning_team
        from {{ ref('nfl_schedules') }} s
        left join {{ ref('nfl_random_num_gen') }} r on r.game_id = s.game_id
        left join cte_seed eh on s.home_team = eh.seed and r.scenario_id = eh.scenario_id
        left join cte_seed ev on s.visiting_team = ev.seed and r.scenario_id = ev.scenario_id
        where s.type = 'playoffs_r1'
    )

select
    e.scenario_id,
    e.series_id,
    e.game_id,
    e.winning_team,
    case when e.winning_team = e.home_team then e.home_team_elo_rating else e.visiting_team_elo_rating end as elo_rating,
    case when e.winning_team = e.home_team then e.home_key else e.visitor_key end as seed,
    {{ var('sim_start_game_id') }} as sim_start_game_id
from cte_step_1 e
-- single-elimination; no series crosswalk needed


