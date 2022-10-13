

SELECT team,
    win_total
FROM '/tmp/storage/raw_team_ratings/*.parquet' S
GROUP BY ALL