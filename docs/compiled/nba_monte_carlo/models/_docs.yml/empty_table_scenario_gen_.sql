

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."scenario_gen"
    HAVING COUNT(*) = 0

