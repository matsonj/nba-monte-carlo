SELECT *
FROM {{ source( 'nba', 'xf_series_to_seed' ) }}
GROUP BY ALL
