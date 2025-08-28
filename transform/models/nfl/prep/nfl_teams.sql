select team as team,
team_short
from {{ ref("nfl_ratings") }}
group by all
