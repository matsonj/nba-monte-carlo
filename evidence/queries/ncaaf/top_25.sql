SELECT
    row_number() over (order by elo_rating DESC) as Rk,
    team,
    conf,
    elo_rating as elo_rating_num0,
    win_range,
    avg_wins as avg_wins_num1,
    record,
    '/ncaaf/teams/' || team as team_link
from src_ncaaf_reg_season_summary
where elo_vs_vegas IS NOT NULL
order by elo_rating DESC
limit 25