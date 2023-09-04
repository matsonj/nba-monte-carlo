

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."ncaaf_prep_team_ratings"
    HAVING COUNT(*) = 0

