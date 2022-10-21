{{
    config(
        materialized = "ephemeral" if target.name == 'parquet' else "view"
) }}

SELECT
    (S._smart_source_lineno - 1)::int AS game_id,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM {{ ref( 'prep_nba_elo_latest' ) }} AS S
LEFT JOIN {{ ref( 'prep_team_ratings' ) }} V ON V.team = S.team2
LEFT JOIN {{ ref( 'prep_team_ratings' ) }} H ON H.team = S.team1
GROUP BY ALL