SELECT
    S.id::int AS game_id,
    S.date,
    S.type,
    S.series_id,
    NULL AS visiting_conf,
    S.VisTm AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.HomeTm AS home_team,
    NULL AS home_team_elo_rating
FROM {{ ref( 'nba_raw_schedule' ) }} AS S
--LEFT JOIN {{ ref( 'nba_ratings' ) }} V ON V.team = S.VisTm
--LEFT JOIN {{ ref( 'nba_ratings' ) }} H ON H.team = S.HomeTm
--LEFT JOIN {{ ref( 'nba_elo_rollforward' ) }} R ON R.game_id = S.id
WHERE S.type <> 'reg_season'
GROUP BY ALL
