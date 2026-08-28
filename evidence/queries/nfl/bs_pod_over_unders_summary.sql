with team_picks as (
    select
        team,
        max(division) as division,
        max(line) as win_total,
        max(pick) filter (where speaker = 'Bill Simmons') as bill_pick,
        max(live_status) filter (where speaker = 'Bill Simmons') as bill_status,
        max(pick) filter (where speaker = 'Cousin Sal') as sal_pick,
        max(live_status) filter (where speaker = 'Cousin Sal') as sal_status
    from src_nfl_bs_pod_over_unders
    where season = 2026
        and conf = 'NFC'
    group by team
)
select
    p.team,
    p.division,
    p.win_total,
    round(r.avg_wins, 1) as proj_wins,
    case
        when r.avg_wins > p.win_total then 'over'
        when r.avg_wins < p.win_total then 'under'
        else 'push'
    end as proj,
    p.bill_pick,
    p.bill_status,
    case
        when p.bill_status = 'On track' then 1
        when p.bill_status = 'Behind' then -1
    end as bill_status_score,
    p.sal_pick,
    p.sal_status,
    case
        when p.sal_status = 'On track' then 1
        when p.sal_status = 'Behind' then -1
    end as sal_status_score
from team_picks p
left join src_nfl_reg_season_summary r on r.team = p.team
order by p.division, p.team
