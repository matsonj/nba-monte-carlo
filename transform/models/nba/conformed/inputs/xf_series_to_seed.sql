SELECT
    series_id,
    seed
FROM {{ ref( 'prep_xf_series_to_seed' ) }}
