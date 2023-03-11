

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."prep_latest_ratings"
    HAVING COUNT(*) = 0

