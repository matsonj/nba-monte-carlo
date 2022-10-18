{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    S.visitorneutral AS team_long,
    R.team
FROM {{ "'/tmp/storage/raw_schedule/*.parquet'" if target.name == 'parquet' 
    else source( 'nba', 'raw_schedule' ) }} AS S
LEFT JOIN {{ ref( 'ratings' ) }} AS R ON R.team_long = S.visitorneutral
GROUP BY ALL
