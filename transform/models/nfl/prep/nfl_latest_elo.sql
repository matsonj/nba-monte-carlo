with
    home_rating as (
        select
            home_team as team,
            max(game_id) game_id,
            max_by(home_team_elo_rating - elo_change, game_id) elo_rating
        from {{ ref("nfl_elo_rollforward") }}
        group by all
    ),
    visiting_rating as (
        select
            visiting_team as team,
            max(game_id) game_id,
            max_by(visiting_team_elo_rating + elo_change, game_id) elo_rating
        from {{ ref("nfl_elo_rollforward") }}
        group by all
    ),
    union_rating as (
        select *
        from home_rating
        union all
        select *
        from visiting_rating
    ),
    final_rating as (
        select team, max_by(elo_rating, game_id) as elo_rating
        from union_rating
        group by all
    )
select
    o.team,
    coalesce(f.elo_rating,o.elo_rating) as elo_rating,
    o.elo_rating as original_rating,
    {{ var("latest_ratings") }} as latest_ratings
from {{ ref("nfl_raw_team_ratings") }} o
left join final_rating f on f.team = o.team

