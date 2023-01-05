

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main"."post_season_schedule"
    HAVING COUNT(*) = 0

