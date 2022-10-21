{{
    config(
      materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team,
    win_total
FROM {{ "'/tmp/storage/raw_team_ratings/*.parquet'" if target.name == 'parquet' 
    else source( 'nba', 'raw_team_ratings' ) }}
GROUP BY ALL
