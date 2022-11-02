SELECT *
FROM {{ ref( 'raw_xf_series_to_seed' ) }}
GROUP BY ALL
