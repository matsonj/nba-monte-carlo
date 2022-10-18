{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating
FROM {{ "'/tmp/storage/raw_team_ratings/*.parquet'" if target.name == 'parquet'
    else source( 'nba', 'raw_team_ratings' ) }}
GROUP BY ALL
