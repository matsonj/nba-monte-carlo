SELECT
    team,
    win_total
FROM {{ ref( 'nba_ratings' ) }}
GROUP BY ALL
