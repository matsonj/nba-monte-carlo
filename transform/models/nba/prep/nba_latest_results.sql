with
    cte_inner as (
        select
            s.id as game_id,
            s."date" as game_date,
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
            {{ var("include_actuals") }} as include_actuals
        from {{ ref("nba_raw_schedule") }} s
        left join
            {{ ref("nba_raw_results") }} r
            on r."date" = s."date"
            and (s.vistm = r.winner or s.vistm = r.loser)
        where home_team_score is not null
        group by all
    ),
    cte_outer as (
        select
            i.*,
            case
                when visiting_team_score > home_team_score
                then 1
                when visiting_team_score = home_team_score
                then 0.5
                else 0
            end as game_result,
            abs(visiting_team_score - home_team_score) as margin,
            w.team as winning_team_short,
            l.team as losing_team_short
        from cte_inner i
        left join {{ ref("nba_teams") }} w on w.team_long = i.winning_team
        left join {{ ref("nba_teams") }} l on l.team_long = i.losing_team
    )
select
    *,
    case
        when margin < 4 and game_result = 1
        then 0.581
        when margin < 4 and game_result = 0
        then 0.419
        when margin < 6 and game_result = 1
        then 0.647
        when margin < 6 and game_result = 0
        then 0.353
        when margin < 9 and game_result = 1
        then 0.745
        when margin < 9 and game_result = 0
        then 0.255
        when margin < 12 and game_result = 1
        then 0.876
        when margin < 12 and game_result = 0
        then 0.124
        else game_result
    end as game_result_v2
from cte_outer
