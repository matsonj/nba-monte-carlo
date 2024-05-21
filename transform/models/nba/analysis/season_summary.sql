{{
    config(
        materialized="table",
        post_hook="COPY {{ this }} TO '../data/data_catalog/{{ this.identifier }}_{{ var('nba_start_date') }}.parquet'",
    )
}}

select
    round(ratings.elo_rating, 0)::int
    || ' ('
    || case when original_rating < elo_rating then '+' else '' end
    || (elo_rating - original_rating)::int
    || ')' as elo_rating,
    r.*,
    p.made_playoffs,
    p.made_conf_semis,
    p.made_conf_finals,
    p.made_finals,
    p.won_finals
from {{ ref("reg_season_summary") }} r
left join {{ ref("playoff_summary") }} p on p.team = r.team
left join {{ ref("nba_ratings") }} ratings on ratings.team = r.team
