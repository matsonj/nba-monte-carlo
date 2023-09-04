SELECT
    *
FROM {{ ref( 'ncaaf_reg_season_schedule' ) }}
/* -- EXCLUDING UNTIL I GET A PLAYOFFS MODULE FIGURED OUT
UNION ALL
SELECT
    *
FROM {{ ref( 'post_season_schedule' ) }}
*/