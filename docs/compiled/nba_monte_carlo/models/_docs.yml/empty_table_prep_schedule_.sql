

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main_prep"."prep_schedule"
    HAVING COUNT(*) = 0

