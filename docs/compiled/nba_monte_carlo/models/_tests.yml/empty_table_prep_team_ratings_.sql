

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "main"."main_prep"."prep_team_ratings"
    HAVING COUNT(*) = 0

