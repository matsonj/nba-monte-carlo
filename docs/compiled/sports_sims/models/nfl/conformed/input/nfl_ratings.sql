SELECT
    orig.team,
    orig.conf,
    orig.division,
    orig.team_short,
    /*  -- ADD BACK WHEN SEASON STARTS
    CASE
        WHEN latest.latest_ratings = true AND latest.elo_rating IS NOT NULL THEN latest.elo_rating
        ELSE orig.elo_rating
    END AS elo_rating,
    */ 
    orig.elo_rating,
    orig.elo_rating AS original_rating,
    orig.win_total
FROM "mdsbox"."main"."nfl_prep_team_ratings" orig
--LEFT JOIN "mdsbox"."main"."prep_elo_post" latest ON latest.team = orig.team
GROUP BY ALL