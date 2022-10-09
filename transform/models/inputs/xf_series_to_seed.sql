SELECT series_id,
    seed
FROM {{ source( 'nba' , 'raw_xf_series_to_seed' ) }}