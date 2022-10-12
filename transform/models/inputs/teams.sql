{{
  config(
    materialized = "ephemeral"
) }}

SELECT S.visitorneutral AS team_long,
    R.team
FROM '/tmp/storage/raw_schedule/*.parquet' S
    LEFT JOIN {{ ref( 'ratings' ) }} R ON R.team_long = S.visitorneutral
GROUP BY ALL