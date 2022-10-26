

SELECT
    S.visitorneutral AS team_long,
    R.team
FROM "main"."main"."prep_schedule" S
LEFT JOIN "main"."main"."ratings" AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL