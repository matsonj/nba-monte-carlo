

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."ncaaf_prep_schedule"
    HAVING COUNT(*) = 0

