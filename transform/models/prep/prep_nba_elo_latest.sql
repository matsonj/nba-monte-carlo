SELECT *
FROM {{ source( 'nba', 'nba_elo_latest' ) }}
GROUP BY ALL
