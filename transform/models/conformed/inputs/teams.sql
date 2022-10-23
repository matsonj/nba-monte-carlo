{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    S.visitorneutral AS team_long,
    R.team
FROM {{ ref( 'prep_schedule' ) }} S
LEFT JOIN {{ ref( 'ratings' ) }} AS R ON R.team_long = S.visitorneutral
WHERE R.team IS NOT NULL
GROUP BY ALL
