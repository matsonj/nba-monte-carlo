SELECT
    *
FROM {{ ref( 'nba_reg_season_schedule' ) }}
UNION ALL
SELECT
    *
FROM {{ ref( 'nba_post_season_schedule' ) }}