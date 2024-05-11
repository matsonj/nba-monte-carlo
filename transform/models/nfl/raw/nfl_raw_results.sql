select
    week as wk,
    "Winner/tie" as winner,
    ptsw as winner_pts,
    "Loser/tie" as loser,
    ptsl as loser_pts,
    case when ptsl = ptsw then 1 else 0 end as tie_flag
from {{ source("nfl", "nfl_results") }}
