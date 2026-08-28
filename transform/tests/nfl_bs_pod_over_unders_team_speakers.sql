select
    season,
    team,
    count(*) as row_count,
    count(distinct speaker) as speaker_count
from {{ ref("nfl_bs_pod_over_unders") }}
group by all
having count(*) <> 2
    or count(distinct speaker) <> 2
