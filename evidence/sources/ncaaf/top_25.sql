SELECT
    team,
    conf,
    elo_rating as elo_rating_num0,
    win_range,
    avg_wins as avg_wins_num1
from ncaaf_reg_season_summary
where elo_vs_vegas IS NOT NULL
order by elo_rating DESC
limit 25