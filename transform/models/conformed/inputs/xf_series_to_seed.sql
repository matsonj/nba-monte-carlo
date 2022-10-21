{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    series_id,
    seed
FROM {{ ref( 'prep_xf_series_to_seed' ) }}
