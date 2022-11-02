SELECT *
FROM {{ ref( 'raw_nba_elo_latest' ) }}
GROUP BY ALL
