

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main_export"."random_num_gen"
    HAVING COUNT(*) = 0

