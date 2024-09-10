with
    cte_inner as (
        select
            s.id as game_id,
            s.week as week_number,
            s.hometm as home_team,
            case
                when s.hometm = r.winner then r.winner_pts else r.loser_pts
            end as home_team_score,
            s.vistm as visiting_team,
            case
                when s.vistm = r.winner then r.winner_pts else r.loser_pts
            end as visiting_team_score,
            r.winner as winning_team,
            r.loser as losing_team,
            {{ var("include_actuals") }} as include_actuals,
            s.neutral as neutral_site
        from {{ ref("nfl_raw_schedule") }} s
        left join
            {{ ref("nfl_raw_results") }} r
            on r.wk = s.week
            and (s.vistm = r.winner or s.vistm = r.loser)
        where home_team_score is not null
        group by all
    ),
    cte_outer as (
        select
            *,
            case
                when visiting_team_score > home_team_score
                then 1
                when visiting_team_score = home_team_score
                then 0.5
                else 0
            end as game_result,
            abs(visiting_team_score - home_team_score) as margin
        from cte_inner
    )
select
    *,
    case
        when margin < 4 and game_result = 1
        then 0.585
        when margin < 4 and game_result = 0
        then 0.415
        when margin < 6 and game_result = 1
        then 0.666
        when margin < 6 and game_result = 0
        then 0.334
        when margin = 6 and game_result = 1
        then 0.707
        when margin = 6 and game_result = 0
        then 0.293
        when margin = 7 and game_result = 1
        then 0.73
        when margin = 7 and game_result = 0
        then 0.27
        when margin = 8 and game_result = 1
        then 0.75
        when margin = 8 and game_result = 0
        then 0.25
        when margin > 8 and margin < 17 and game_result = 1
        then 0.85
        when margin > 8 and margin < 17 and game_result = 0
        then 0.15
        else game_result
    end as game_result_v2
from cte_outer
