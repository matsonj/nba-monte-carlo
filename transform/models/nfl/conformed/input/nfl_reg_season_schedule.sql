SELECT
    S.id AS game_id,
    S.week as week_number,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    R.visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    R.home_team_elo_rating
FROM {{ ref( 'nfl_prep_schedule' ) }} AS S
LEFT JOIN {{ ref( 'nfl_ratings' ) }} V ON V.team = S.VisTm
LEFT JOIN {{ ref( 'nfl_ratings' ) }} H ON H.team = S.HomeTm
LEFT JOIN {{ ref( 'nfl_elo_rollforward' ) }} R ON R.game_id = S.id
GROUP BY ALL
