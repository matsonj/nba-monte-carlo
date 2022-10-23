{{
    config(
      materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    team,
    win_total
FROM {{ ref( 'ratings' ) }}
GROUP BY ALL
