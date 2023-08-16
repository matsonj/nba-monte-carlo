SELECT
    team,
    win_total
FROM {{ ref( 'nfl_ratings' ) }}
GROUP BY ALL
