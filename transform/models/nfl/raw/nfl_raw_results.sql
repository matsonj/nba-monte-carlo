-- casts are explicit because the csv sniffer types the score columns as varchar
-- at season start, when no game is completed and every score is null
select
    cast(week as bigint) as wk,
    winner,
    cast(winner_pts as bigint) as winner_pts,
    loser,
    cast(loser_pts as bigint) as loser_pts,
    case when loser_pts = winner_pts then 1 else 0 end as tie_flag
from {{ source("nfl_dlt", "games") }}
where completed
