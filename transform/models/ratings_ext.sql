SELECT R.*,
  S.*
FROM {{ ref( 'ratings' ) }} R
  LEFT JOIN {{ ref('reg_season_summary' ) }} S ON S.team = R.team
GROUP BY ALL