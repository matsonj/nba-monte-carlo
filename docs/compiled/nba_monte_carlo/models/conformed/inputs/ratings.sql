

SELECT
    orig.team,
    orig.team_long,
    orig.conf,
    CASE
        WHEN latest.latest_ratings = true THEN latest.elo_rating::int
        ELSE orig.elo_rating::int
    END AS elo_rating,
    orig.elo_rating::int AS original_rating,
    orig.win_total
FROM "main"."main_prep"."prep_team_ratings" orig
LEFT JOIN "main"."main_prep"."prep_latest_ratings" latest ON latest.team = orig.team
GROUP BY ALL