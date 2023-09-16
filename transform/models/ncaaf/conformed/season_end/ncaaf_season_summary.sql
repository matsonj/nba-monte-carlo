{{ 
    config(
        materialized='external'
) }}

SELECT
    ROUND(ratings.elo_rating,0)::int || ' (' || CASE WHEN original_rating < ratings.elo_rating THEN '+' ELSE '' END || (ratings.elo_rating-original_rating)::int || ')' AS elo_rating,
    R.*
FROM {{ ref( 'ncaaf_reg_season_summary' ) }} R
-- LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team
LEFT JOIN {{ ref( 'ncaaf_ratings' ) }} ratings ON ratings.team = R.team