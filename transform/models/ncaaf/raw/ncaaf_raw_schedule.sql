SELECT *
FROM {{ source( 'ncaaf', 'ncaaf_schedule' ) }}
