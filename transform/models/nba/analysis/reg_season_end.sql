with
    cte_wins as (
        select
            s.scenario_id,
            s.winning_team,
            case
                when s.winning_team = s.home_team then s.home_conf else s.visiting_conf
            end as conf,
            /*    CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS elo_rating, */
            count(*) as wins
        from {{ ref("reg_season_simulator") }} s
        group by all
    ),

    cte_ranked_wins as (
        select
            scenario_id,
            team as winning_team,
            conference as conf,
            wins,
            rank as season_rank
        from {{ ref("nba_tiebreakers_optimized") }}

    ),

    cte_made_playoffs as (
        select
            *,
            case when season_rank <= 10 then 1 else 0 end as made_playoffs,
            case when season_rank between 7 and 10 then 1 else 0 end as made_play_in,
            conf || '-' || season_rank::text as seed
        from cte_ranked_wins
    )

select mp.*, le.elo_rating, {{ var("sim_start_game_id") }} as sim_start_game_id
from cte_made_playoffs mp
left join {{ ref("nba_latest_elo") }} le on le.team = mp.winning_team
