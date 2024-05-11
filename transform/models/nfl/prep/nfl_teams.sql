select s.vistm as team_long,
-- R.team
from {{ ref("nfl_raw_schedule") }} s
-- LEFT JOIN {{ ref( 'nfl_ratings' ) }} AS R ON R.team = S.VisTm
-- WHERE R.team IS NOT NULL
group by all
