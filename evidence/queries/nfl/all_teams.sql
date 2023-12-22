SELECT
    row_number() over (order by elo_rating DESC) as Rk,
    team,
    conf,
    elo_rating as elo_rating_num0,
    win_range,
    avg_wins as avg_wins_num1,
    record,
    '/nfl/teams/' || team as team_link,
    COALESCE((made_postseason + first_round_bye) / 10000.0,0) as make_playoffs_pct1
from src_nfl_reg_season_summary
where elo_vs_vegas IS NOT NULL
order by elo_rating DESC