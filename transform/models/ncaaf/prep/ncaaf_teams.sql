select s.vistm as team_long,
-- R.team
from {{ ref("ncaaf_raw_schedule") }} s
-- LEFT JOIN {{ ref( 'ncaaf_ratings' ) }} AS R ON R.team = S.VisTm
-- WHERE R.team IS NOT NULL
group by all
