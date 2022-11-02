select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

    with __dbt__cte__raw_schedule as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_schedule_2023/*.parquet'
),  __dbt__cte__prep_schedule as (
SELECT *
FROM __dbt__cte__raw_schedule
),  __dbt__cte__post_season_schedule as (
SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM __dbt__cte__prep_schedule AS S
WHERE S.type <> 'reg_season'
GROUP BY ALL
)SELECT COALESCE(COUNT(*),0) AS records
    FROM __dbt__cte__post_season_schedule
    HAVING COUNT(*) = 0


      
    ) dbt_internal_test