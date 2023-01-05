

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."prep_xf_series_to_seed"
    HAVING COUNT(*) = 0

