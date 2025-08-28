select
    s.id as game_id,
    s.week as week_number,
    case
        when s.week <= 18 then 'reg_season'
        when s.week = 19 then 'playoffs_r1'
        when s.week = 20 then 'playoffs_r2'
        when s.week = 21 then 'playoffs_r3'
        when s.week = 22 then 'playoffs_r4'
    end as type,
    0 as series_id,
    coalesce(v.conf,
        case
            when s.vistm like 'AFC-%' then 'AFC'
            when s.vistm like 'NFC-%' then 'NFC'
        end
    ) as visiting_conf,
    s.vistm as visiting_team,
    case when s.week <= 18 then coalesce(r.visiting_team_elo_rating, v.elo_rating::int) end as visiting_team_elo_rating,
    coalesce(h.conf,
        case
            when s.hometm like 'AFC-%' then 'AFC'
            when s.hometm like 'NFC-%' then 'NFC'
        end
    ) as home_conf,
    s.hometm as home_team,
    case when s.week <= 18 then coalesce(r.home_team_elo_rating, h.elo_rating::int) end as home_team_elo_rating,
    s.neutral as neutral_site,
    case when s.neutral = 0 then {{ var("nfl_elo_offset") }} else 0 end as game_site_adjustment
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
    
