

SELECT S.visitorneutral AS team_long,
    R.team
FROM "main"."main"."raw_schedule" S
    LEFT JOIN "main"."main"."ratings" R ON R.team_long = S.visitorneutral
GROUP BY ALL