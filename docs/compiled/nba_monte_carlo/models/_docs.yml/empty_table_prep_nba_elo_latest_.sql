

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."prep_nba_elo_latest"
    HAVING COUNT(*) = 0

