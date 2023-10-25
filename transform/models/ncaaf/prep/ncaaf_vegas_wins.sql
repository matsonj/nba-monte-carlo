SELECT
    team,
    win_total
FROM {{ ref( 'ncaaf_ratings' ) }}
GROUP BY ALL
