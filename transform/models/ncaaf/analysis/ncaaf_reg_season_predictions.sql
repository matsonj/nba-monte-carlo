select
    game_id,
    home_team,
    home.team as home_short,
    home_team_elo_rating,
    visiting_team,
    visitor.team as vis_short,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    count(*) as occurances,
    {{ american_odds("home_team_win_probability/10000") }} as american_odds
from {{ ref("ncaaf_reg_season_simulator") }} s
left join {{ ref("ncaaf_ratings") }} home on home.team = s.home_team
left join {{ ref("ncaaf_ratings") }} visitor on visitor.team = s.visiting_team
group by all
