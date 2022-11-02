SELECT
    *
FROM {{ ref( 'reg_season_schedule' ) }}
UNION ALL
SELECT
    *
FROM {{ ref( 'post_season_schedule' ) }}