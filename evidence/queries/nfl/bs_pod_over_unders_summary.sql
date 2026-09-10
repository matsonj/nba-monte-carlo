with team_picks as (
    select
        team,
        max(conf) as conf,
        max(division) as division,
        max(line) as win_total,
        max(projected_wins) as proj_wins,
        max(projected_side) as proj,
        max(pick) filter (where speaker = 'Bill Simmons') as bill_pick,
        max(live_status) filter (where speaker = 'Bill Simmons') as bill_status,
        max(pick) filter (where speaker = 'Cousin Sal') as sal_pick,
        max(live_status) filter (where speaker = 'Cousin Sal') as sal_status
    from src_nfl_bs_pod_over_unders
    where season = 2026
    group by team
)
select
    conf,
    team,
    division,
    win_total,
    proj_wins,
    proj,
    bill_pick,
    case bill_status
        when 'On track' then '✅ On track'
        when 'Win' then '✅ Win'
        when 'Behind' then '❌ Behind'
        when 'Loss' then '❌ Loss'
        when 'Push' then '➖ Push'
        else bill_status
    end as bill_status,
    sal_pick,
    case sal_status
        when 'On track' then '✅ On track'
        when 'Win' then '✅ Win'
        when 'Behind' then '❌ Behind'
        when 'Loss' then '❌ Loss'
        when 'Push' then '➖ Push'
        else sal_status
    end as sal_status
from team_picks
order by conf, division, team
