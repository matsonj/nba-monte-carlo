{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

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
FROM {{ ref( 'prep_team_ratings' ) }} orig
LEFT JOIN {{ ref( 'prep_latest_ratings' )}} latest ON latest.team = orig.team
GROUP BY ALL
