{{ 
    config(
        materialized='external', 
        location="/tmp/data_catalog/conformed/" ~ this.name ~ ".parquet"
) }}

SELECT
    ratings.elo_rating || ' (' || CASE WHEN original_rating < elo_rating THEN '+' ELSE '' END || (elo_rating-original_rating)::int || ')' AS elo_rating,
    R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM {{ ref( 'reg_season_summary' ) }} R
LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team
LEFT JOIN {{ ref( 'ratings' ) }} ratings ON ratings.team = R.team
