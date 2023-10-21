SELECT
    S.visitorneutral AS team_long,
    R.team
FROM {{ ref( 'nba_schedules' ) }} S
LEFT JOIN {{ ref( 'nba_ratings' ) }} AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL
