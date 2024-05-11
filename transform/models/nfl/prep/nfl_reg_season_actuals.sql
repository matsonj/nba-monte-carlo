with
    cte_wins as (
        select winning_team, count(*) as wins
        from {{ ref("nfl_latest_results") }}
        group by all
    ),

    cte_losses as (
        select losing_team, count(*) as losses
        from {{ ref("nfl_latest_results") }}
        group by all
    )

select t.team_long as team, coalesce(w.wins, 0) as wins, coalesce(l.losses, 0) as losses
from {{ ref("nfl_teams") }} t
left join cte_wins w on w.winning_team = t.team_long
left join cte_losses l on l.losing_team = t.team_long
