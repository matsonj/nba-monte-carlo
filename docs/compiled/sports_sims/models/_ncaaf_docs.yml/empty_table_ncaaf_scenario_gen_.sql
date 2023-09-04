

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."ncaaf_scenario_gen"
    HAVING COUNT(*) = 0

