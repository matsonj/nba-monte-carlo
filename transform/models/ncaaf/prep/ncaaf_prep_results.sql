SELECT *
FROM {{ source( 'ncaaf', 'ncaaf_results' ) }}
