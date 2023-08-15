SELECT
    S.VisTm AS team_long,
   -- R.team
FROM "mdsbox"."main"."nfl_prep_schedule" S
--LEFT JOIN "mdsbox"."main"."nfl_ratings" AS R ON R.team = S.VisTm
--WHERE R.team IS NOT NULL
GROUP BY ALL