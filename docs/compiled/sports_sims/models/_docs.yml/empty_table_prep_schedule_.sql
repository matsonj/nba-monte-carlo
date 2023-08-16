

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."prep_schedule"
    HAVING COUNT(*) = 0

