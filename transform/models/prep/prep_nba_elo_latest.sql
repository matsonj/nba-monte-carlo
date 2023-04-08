SELECT *
FROM {{ source( 'nba', 'nba_elo_latest' ) }}
WHERE date::date <= '2023-04-09'
GROUP BY ALL
