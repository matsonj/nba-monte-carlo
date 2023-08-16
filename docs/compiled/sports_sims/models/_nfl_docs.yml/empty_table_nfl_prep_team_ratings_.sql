

    SELECT COALESCE(COUNT(*),0) AS records
    FROM "mdsbox"."main"."nfl_prep_team_ratings"
    HAVING COUNT(*) = 0

