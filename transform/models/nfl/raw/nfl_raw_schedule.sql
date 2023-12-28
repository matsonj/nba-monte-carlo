SELECT *
FROM {{ source( 'nfl', 'nfl_schedule' ) }}
