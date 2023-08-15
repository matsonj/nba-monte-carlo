SELECT
    S.VisTm AS team_long,
   -- R.team
FROM {{ ref( 'nfl_prep_schedule' ) }} S
--LEFT JOIN {{ ref( 'nfl_ratings' ) }} AS R ON R.team = S.VisTm
--WHERE R.team IS NOT NULL
GROUP BY ALL
