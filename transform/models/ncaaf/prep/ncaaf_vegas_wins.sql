select team, win_total from {{ ref("ncaaf_ratings") }} group by all
