select
    orig.team,
    orig.conf,
    orig.division,
    orig.team_short,
    case
        when latest.latest_ratings = true and latest.elo_rating is not null
        then latest.elo_rating
        else orig.elo_rating
    end as elo_rating,
    orig.elo_rating as original_rating,
    orig.win_total
from {{ ref("nfl_raw_team_ratings") }} orig
left join {{ ref("nfl_latest_elo") }} latest on latest.team = orig.team
group by all
