select team as team
from {{ ref("nfl_ratings") }}
group by all
