select
    r.scenario_id,
    s.*,
    {{
        elo_calc(
            "S.home_team_elo_rating",
            "S.visiting_team_elo_rating",
            0 if "s.neutral_site" == 1 else var("nfl_elo_offset")
        )
    }} as home_team_win_probability,
    r.rand_result,
    case
        when lr.include_actuals = 'true'
            then lr.winning_team
        when
            ({{
                elo_calc(
                    "S.home_team_elo_rating",
                    "S.visiting_team_elo_rating",
                    0 if "s.neutral_site" == 1 else var("nfl_elo_offset")
                )
            }})::int >= r.rand_result
        then s.home_team
        else s.visiting_team
    end as winning_team,
    coalesce(lr.include_actuals, false) as include_actuals
from {{ ref("nfl_schedules") }} s
left join {{ ref("nfl_random_num_gen") }} r on r.game_id = s.game_id
left join {{ ref("nfl_latest_results") }} lr on lr.game_id = s.game_id
where s.type = 'reg_season'
