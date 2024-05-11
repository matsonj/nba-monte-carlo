with
    cte_summary as (
        select
            winning_team as team,
            e.conf,
            round(avg(wins), 1) as avg_wins,
            v.win_total as vegas_wins,
            round(avg(v.win_total) - avg(wins), 1) as elo_vs_vegas,
            round(
                percentile_cont(0.05) within group (order by wins asc), 1
            ) as wins_5th,
            round(
                percentile_cont(0.95) within group (order by wins asc), 1
            ) as wins_95th,
            count(*) filter (
                where made_playoffs = 1 and first_round_bye = 0
            ) as made_postseason,
            count(*) filter (where first_round_bye = 1) as first_round_bye,
            round(
                percentile_cont(0.05) within group (order by season_rank asc), 1
            ) as seed_5th,
            round(avg(season_rank), 1) as avg_seed,
            round(
                percentile_cont(0.95) within group (order by season_rank asc), 1
            ) as seed_95th
        from {{ ref("ncaaf_reg_season_end") }} e
        left join {{ ref("ncaaf_vegas_wins") }} v on v.team = e.winning_team
        group by all
    )

select
    c.conf,
    sum(a.wins) || ' - ' || sum(a.losses) as record,
    sum(c.avg_wins) as tot_wins,
    sum(c.vegas_wins) as vegas_wins,
    avg(r.elo_rating) as avg_elo_rating,
    sum(c.elo_vs_vegas) as elo_vs_vegas,
    count(*) as teams
from cte_summary c
left join {{ ref("ncaaf_reg_season_actuals") }} a on a.team = c.team
left join {{ ref("ncaaf_ratings") }} r on r.team = c.team
group by all
