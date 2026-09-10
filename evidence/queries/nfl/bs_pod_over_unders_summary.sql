-- display labels for each pick status, joined once before the speaker pivot
with status_labels (live_status, label) as (
    values
        ('On track', '🟢 On track'),
        ('Behind',   '🔴 Behind'),
        ('Win',      '✅ Win'),
        ('Loss',     '❌ Loss'),
        ('Push',     '➖ Push')
),

picks as (
    select
        p.team,
        p.conf,
        p.division,
        p.line,
        p.projected_wins,
        p.projected_side,
        p.speaker,
        p.pick,
        coalesce(l.label, p.live_status) as status
    from src_nfl_bs_pod_over_unders p
    left join status_labels l on l.live_status = p.live_status
    where p.season = 2026
)

select
    conf,
    team,
    division,
    max(line) as win_total,
    max(projected_wins) as proj_wins,
    max(projected_side) as proj,
    max(pick) filter (where speaker = 'Bill Simmons') as bill_pick,
    max(status) filter (where speaker = 'Bill Simmons') as bill_status,
    max(pick) filter (where speaker = 'Cousin Sal') as sal_pick,
    max(status) filter (where speaker = 'Cousin Sal') as sal_status
from picks
group by conf, team, division
order by conf, division, team
