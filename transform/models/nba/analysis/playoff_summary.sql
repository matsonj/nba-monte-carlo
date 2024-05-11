with
    cte_playoffs_r1 as (
        select winning_team, count(*) as made_playoffs
        from {{ ref("initialize_seeding") }}
        group by all
    ),

    cte_playoffs_r2 as (
        select winning_team, count(*) as made_conf_semis
        from {{ ref("playoff_sim_r1") }}
        group by all
    ),

    cte_playoffs_r3 as (
        select winning_team, count(*) as made_conf_finals
        from {{ ref("playoff_sim_r2") }}
        group by all
    ),

    cte_playoffs_r4 as (
        select winning_team, count(*) as made_finals
        from {{ ref("playoff_sim_r3") }}
        group by all
    ),

    cte_playoffs_finals as (
        select winning_team, count(*) as won_finals
        from {{ ref("playoff_sim_r4") }}
        group by all
    )

select
    t.team,
    r1.made_playoffs,
    r2.made_conf_semis,
    r3.made_conf_finals,
    r4.made_finals,
    f.won_finals
from {{ ref("nba_teams") }} t
left join cte_playoffs_r1 r1 on r1.winning_team = t.team
left join cte_playoffs_r2 r2 on r2.winning_team = t.team
left join cte_playoffs_r3 r3 on r3.winning_team = t.team
left join cte_playoffs_r4 r4 on r4.winning_team = t.team
left join cte_playoffs_finals f on f.winning_team = t.team
