





with __dbt__cte__ratings as (






SELECT
    team,
    team_long,
    conf,
    elo_rating::int AS elo_rating

FROM '/tmp/storage/raw_team_ratings/*.parquet'

GROUP BY ALL
)SELECT
    S.visitorneutral AS team_long,
    R.team

FROM '/tmp/storage/raw_schedule/*.parquet' AS S

    LEFT JOIN __dbt__cte__ratings R ON R.team_long = S.visitorneutral
GROUP BY ALL