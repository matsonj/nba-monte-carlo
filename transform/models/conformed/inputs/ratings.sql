{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    orig.team,
    orig.team_long,
    orig.conf,
    CASE
        WHEN latest.latest_ratings = true THEN latest.elo_rating
        ELSE orig.elo_rating
    END AS elo_rating,
    orig.elo_rating AS original_rating,
    orig.win_total
FROM {{ ref( 'prep_team_ratings' ) }} orig
LEFT JOIN {{ ref( 'prep_elo_post' ) }} latest ON latest.team = orig.team
GROUP BY ALL
