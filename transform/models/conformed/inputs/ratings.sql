{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating
FROM {{ ref( 'prep_team_ratings' ) }}
GROUP BY ALL
