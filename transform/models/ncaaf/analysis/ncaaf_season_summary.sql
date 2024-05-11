select
    round(ratings.elo_rating, 0)::int
    || ' ('
    || case when original_rating < ratings.elo_rating then '+' else '' end
    || (ratings.elo_rating - original_rating)::int
    || ')' as elo_rating,
    r.*
from {{ ref("ncaaf_reg_season_summary") }} r
-- LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team
left join {{ ref("ncaaf_ratings") }} ratings on ratings.team = r.team
