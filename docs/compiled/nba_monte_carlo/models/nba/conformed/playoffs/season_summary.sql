

SELECT
    ROUND(ratings.elo_rating,0)::int || ' (' || CASE WHEN original_rating < elo_rating THEN '+' ELSE '' END || (elo_rating-original_rating)::int || ')' AS elo_rating,
    R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM "mdsbox"."main"."reg_season_summary" R
LEFT JOIN "mdsbox"."main"."playoff_summary" P ON P.team = R.team
LEFT JOIN "mdsbox"."main"."ratings" ratings ON ratings.team = R.team