{{
    config(
        materialized="view"
    )
}}

select
    round(ratings.elo_rating, 0)::int
    || ' ('
    || case when ratings.original_rating < ratings.elo_rating then '+' else '' end
    || (ratings.elo_rating - ratings.original_rating)::int
    || ')' as elo_rating,
    r.*,
    p.made_playoffs,
    p.made_conf_semis,
    p.made_conf_finals,
    p.made_finals,
    p.won_finals
from {{ ref("nfl_reg_season_summary") }} r
left join {{ ref("nfl_playoff_summary") }} p on p.team = r.team
left join {{ ref("nfl_ratings") }} ratings on ratings.team = r.team


