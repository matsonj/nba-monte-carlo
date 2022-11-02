
    
    

with __dbt__cte__raw_team_ratings as (
SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
),  __dbt__cte__prep_team_ratings as (
SELECT *
FROM __dbt__cte__raw_team_ratings
),  __dbt__cte__prep_elo_post as (
SELECT
    *,
    True AS latest_ratings
FROM '/tmp/data_catalog/prep/elo_post.parquet'
),  __dbt__cte__ratings as (
SELECT
    orig.team,
    orig.team_long,
    orig.conf,
    CASE
        WHEN latest.latest_ratings = true AND latest.elo_rating IS NOT NULL THEN latest.elo_rating
        ELSE orig.elo_rating
    END AS elo_rating,
    orig.elo_rating AS original_rating,
    orig.win_total
FROM __dbt__cte__prep_team_ratings orig
LEFT JOIN __dbt__cte__prep_elo_post latest ON latest.team = orig.team
GROUP BY ALL
),  __dbt__cte__vegas_wins as (
SELECT
    team,
    win_total
FROM __dbt__cte__ratings
GROUP BY ALL
)select
    team as unique_field,
    count(*) as n_records

from __dbt__cte__vegas_wins
where team is not null
group by team
having count(*) > 1


