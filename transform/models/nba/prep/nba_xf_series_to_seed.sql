SELECT
    series_id,
    seed
FROM {{ ref( 'nba_raw_xf_series_to_seed' ) }}
