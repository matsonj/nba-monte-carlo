SELECT
    team,
    win_total
FROM {{ ref( 'ratings' ) }}
GROUP BY ALL
