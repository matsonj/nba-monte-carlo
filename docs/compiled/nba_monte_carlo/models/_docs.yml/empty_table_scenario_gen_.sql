

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."scenario_gen"
    HAVING COUNT(*) = 0

