SELECT
    S.id AS game_id,
    S.week as week_number,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM "mdsbox"."main"."ncaaf_prep_schedule" AS S
LEFT JOIN "mdsbox"."main"."ncaaf_ratings" V ON V.team = S.VisTm
LEFT JOIN "mdsbox"."main"."ncaaf_ratings" H ON H.team = S.HomeTm
GROUP BY ALL