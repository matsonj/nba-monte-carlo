SELECT *
FROM {{ source( 'nba', 'schedule' ) }}
