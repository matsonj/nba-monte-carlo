select
    speaker,
    count(*) filter (where regular_season_complete and final_result = 'Win') as settled_wins,
    count(*) filter (where regular_season_complete and final_result = 'Loss') as settled_losses,
    count(*) filter (where regular_season_complete and final_result = 'Push') as settled_pushes,
    count(*) filter (where not regular_season_complete) as open_picks,
    count(*) filter (where not regular_season_complete and live_status = 'On track') as on_track,
    count(*) filter (where not regular_season_complete and live_status = 'Behind') as behind,
    count(*) as total_picks
from src_nfl_bs_pod_over_unders
where season = 2026
    and conf = 'NFC'
group by speaker
order by speaker
