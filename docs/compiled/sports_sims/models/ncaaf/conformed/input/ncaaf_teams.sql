SELECT
    S.VisTm AS team_long,
   -- R.team
FROM "mdsbox"."main"."ncaaf_prep_schedule" S
--LEFT JOIN "mdsbox"."main"."ncaaf_ratings" AS R ON R.team = S.VisTm
--WHERE R.team IS NOT NULL
GROUP BY ALL