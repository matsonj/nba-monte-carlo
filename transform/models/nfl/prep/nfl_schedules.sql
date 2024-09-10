select
    s.id as game_id,
    s.week as week_number,
    'reg_season' as type,
    0 as series_id,
    v.conf as visiting_conf,
    v.team as visiting_team,
    coalesce(r.visiting_team_elo_rating, v.elo_rating::int) as visiting_team_elo_rating,
    h.conf as home_conf,
    h.team as home_team,
    coalesce(r.home_team_elo_rating, h.elo_rating::int) as home_team_elo_rating,
    s.neutral as neutral_site
from {{ ref("nfl_raw_schedule") }} as s
left join {{ ref("nfl_ratings") }} v on v.team = s.vistm
left join {{ ref("nfl_ratings") }} h on h.team = s.hometm
left join {{ ref("nfl_elo_rollforward") }} r on r.game_id = s.id
group by
    all

    /* -- EXCLUDING UNTIL I GET A PLAYOFFS MODULE FIGURED OUT
UNION ALL
SELECT
    *
FROM {{ ref( 'nba_post_season_schedule' ) }}
*/
    
