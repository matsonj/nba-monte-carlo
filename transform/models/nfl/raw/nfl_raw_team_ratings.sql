select
    "Team" as team,
    "Team_short" as team_short,
    "Win Total" as win_total,
    "ELO rating" as elo_rating,
    "Conf" as conf,
    "Division" as division
from {{ source("nfl", "nfl_team_ratings") }}
