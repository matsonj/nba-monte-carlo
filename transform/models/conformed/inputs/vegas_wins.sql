{{
    config(
      materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team,
    win_total
FROM {{ ref( 'prep_team_ratings' ) }}
GROUP BY ALL
