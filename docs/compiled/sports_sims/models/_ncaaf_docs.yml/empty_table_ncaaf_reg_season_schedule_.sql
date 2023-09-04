

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."ncaaf_reg_season_schedule"
    HAVING COUNT(*) = 0

