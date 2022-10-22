

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main_prep"."prep_xf_series_to_seed"
    HAVING COUNT(*) = 0

