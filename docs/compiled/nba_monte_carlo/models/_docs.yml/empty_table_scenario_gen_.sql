

    with __dbt__cte__scenario_gen as (
SELECT I.generate_series AS scenario_id
FROM generate_series(1, 10000 ) AS I
)SELECT COALESCE(COUNT(*),0) AS records
    FROM __dbt__cte__scenario_gen
    HAVING COUNT(*) = 0

