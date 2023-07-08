SELECT *
FROM '/home/jacob/mdsinabox/nba-monte-carlo/data/data_catalog/psa/nba_elo_latest/*.parquet'
WHERE date::date <= '2023-04-09'
GROUP BY ALL