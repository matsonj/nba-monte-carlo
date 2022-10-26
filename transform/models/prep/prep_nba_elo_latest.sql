{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ ref( 'raw_nba_elo_latest' ) }}
GROUP BY ALL