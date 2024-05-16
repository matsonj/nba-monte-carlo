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
        from {{ ref("nfl_reg_season_end") }} e
        left join {{ ref("nfl_vegas_wins") }} v on v.team = e.winning_team
        group by all
    )

select
    c.team,
    c.conf,
    a.wins::int || ' - ' || a.losses::int as record,
    c.avg_wins,
    c.vegas_wins,
    r.elo_rating,
    c.elo_vs_vegas,
    c.wins_5th::int || ' to ' || c.wins_95th::int as win_range,
    c.seed_5th::int || ' to ' || c.seed_95th::int as seed_range,
    c.made_postseason,
    c.first_round_bye,
    {{ var("sim_start_game_id") }} as sim_start_game_id
from cte_summary c
left join 'nfl_reg_season_actuals' a on a.team = c.team
left join {{ ref("nfl_ratings") }} r on r.team = c.team
