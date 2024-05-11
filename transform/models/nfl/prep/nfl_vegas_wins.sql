select team, win_total from {{ ref("nfl_ratings") }} group by all
