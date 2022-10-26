

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."prep_schedule"
    HAVING COUNT(*) = 0

