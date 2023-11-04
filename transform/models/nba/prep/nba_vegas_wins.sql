SELECT
    team,
    win_total::double as win_total
FROM {{ ref( 'nba_ratings' ) }}
GROUP BY ALL
