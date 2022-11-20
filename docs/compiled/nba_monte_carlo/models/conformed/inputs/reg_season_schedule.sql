with __dbt__cte__prep_nba_elo_latest as (
SELECT *
FROM '/tmp/data_catalog/psa/nba_elo_latest/*.parquet'
GROUP BY ALL
),  __dbt__cte__prep_team_ratings as (
SELECT *
FROM '/tmp/data_catalog/psa/team_ratings/*.parquet'
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
)SELECT
    (S._smart_source_lineno - 1)::int AS game_id,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM __dbt__cte__prep_nba_elo_latest AS S
LEFT JOIN __dbt__cte__ratings V ON V.team = S.team2
LEFT JOIN __dbt__cte__ratings H ON H.team = S.team1
GROUP BY ALL