

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."random_num_gen"
    HAVING COUNT(*) = 0

