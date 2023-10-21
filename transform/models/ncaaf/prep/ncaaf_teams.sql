SELECT
    S.VisTm AS team_long,
   -- R.team
FROM {{ ref( 'ncaaf_raw_schedule' ) }} S
--LEFT JOIN {{ ref( 'ncaaf_ratings' ) }} AS R ON R.team = S.VisTm
--WHERE R.team IS NOT NULL
GROUP BY ALL
