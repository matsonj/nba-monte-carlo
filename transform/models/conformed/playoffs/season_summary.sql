-- depends-on: {{ ref( 'reg_season_summary' ) }}

{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO 's3://datalake/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

SELECT
    ratings.elo_rating || ' (' || CASE WHEN original_rating < elo_rating THEN '+' ELSE '' END || (elo_rating-original_rating)::int || ')' AS elo_rating,
    R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM {{ "'s3://datalake/conformed/reg_season_summary.parquet'" if target.name == 'parquet'
    else ref( 'reg_season_summary' ) }} R
LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team
LEFT JOIN {{ ref( 'ratings' ) }} ratings ON ratings.team = R.team
