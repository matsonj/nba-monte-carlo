{{
    config(
        materialized="table"
    )
}}

with
    cte_summary as (
        select
            winning_team as team,
            e.conf,
            round(avg(wins), 1) as avg_wins,
            v.win_total as vegas_wins,
            round(avg(v.win_total) - (avg(wins)), 1) as elo_vs_vegas,
            round(
                percentile_cont(0.05) within group (order by wins asc), 1
            ) as wins_5th,
            round(
                percentile_cont(0.95) within group (order by wins asc), 1
            ) as wins_95th,
            count(*) filter (
                where made_playoffs = 1 and made_play_in = 0
            ) as made_postseason,
            count(*) filter (where made_play_in = 1) as made_play_in,
            round(
                percentile_cont(0.05) within group (order by season_rank asc), 1
            ) as seed_5th,
            round(avg(season_rank), 1) as avg_seed,
            round(
                percentile_cont(0.95) within group (order by season_rank asc), 1
            ) as seed_95th
        from {{ ref("reg_season_end") }} e
        left join {{ ref("nba_vegas_wins") }} v on v.team = e.winning_team
        group by all
    )

select
    c.team,
    c.conf,
    a.wins || ' - ' || a.losses as record,
    c.avg_wins,
    c.vegas_wins,
    c.elo_vs_vegas,
    c.wins_5th::int || ' to ' || c.wins_95th::int as win_range,
    c.seed_5th::int || ' to ' || c.seed_95th::int as seed_range,
    c.made_postseason,
    c.made_play_in,
    '{{ var("nba_start_date") }}'::date as nba_sim_start_date
from cte_summary c
left join {{ ref("nba_reg_season_actuals") }} a on a.team = c.team
