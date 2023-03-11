

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."random_num_gen"
    HAVING COUNT(*) = 0

