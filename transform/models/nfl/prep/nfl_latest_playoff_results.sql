-- Playoff results joined by week and team matchup (not game_id, since schedule uses seed placeholders)
-- This model expects the playoff simulator to provide resolved team names for joining
select
    r.wk as week_number,
    r.winner as winning_team,
    r.winner_pts,
    r.loser as losing_team,
    r.loser_pts,
    {{ var("include_actuals") }} as include_actuals
from {{ ref("nfl_raw_results") }} r
where r.wk >= 19
