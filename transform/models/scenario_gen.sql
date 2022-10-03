{{
  config(
    materialized = "table"
) }}

SELECT i.generate_series as scenario_id,
    CASE 
        WHEN i.generate_series <= 100000 / 4 THEN 1
        WHEN i.generate_series > 100000 / 4 AND i.generate_series <= (100000 / 4 )* 2 THEN 2
        WHEN i.generate_series > (100000 / 4) * 2 AND i.generate_series <= (100000 / 4 )* 3 THEN 3
        WHEN i.generate_series > (100000 / 4) * 3 AND i.generate_series <= 100000 THEN 4
        ELSE -1
    END AS partition_id
FROM generate_series(1,100000) i