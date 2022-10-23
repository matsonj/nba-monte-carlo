

  create  table
    "main"."season_summary__dbt_tmp"
  as (
    -- depends-on: "main"."main"."reg_season_summary"



SELECT
    ratings.elo_rating || ' (' || CASE WHEN original_rating < elo_rating THEN '+' ELSE '' END || (elo_rating-original_rating)::int || ')' AS elo_rating,
    R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM "main"."main"."reg_season_summary" R
LEFT JOIN "main"."main"."playoff_summary" P ON P.team = R.team
LEFT JOIN "main"."main"."ratings" ratings ON ratings.team = R.team
  );

