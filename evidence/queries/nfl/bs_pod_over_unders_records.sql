select
    speaker,
    count(*) filter (where is_settled and final_result = 'Win') as settled_wins,
    count(*) filter (where is_settled and final_result = 'Loss') as settled_losses,
    count(*) filter (where is_settled and final_result = 'Push') as settled_pushes,
    count(*) filter (where not is_settled) as open_picks,
    count(*) filter (where not is_settled and live_status = 'On track') as on_track,
    count(*) filter (where not is_settled and live_status = 'Behind') as behind
from src_nfl_bs_pod_over_unders
where season = 2026
group by speaker
order by speaker
