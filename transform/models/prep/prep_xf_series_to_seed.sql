{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT *
FROM {{ ref( 'raw_xf_series_to_seed' ) }}
GROUP BY ALL