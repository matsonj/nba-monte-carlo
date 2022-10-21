

SELECT
    S.key::int AS game_id,
    S.type,
    S.series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM "main"."main_prep"."prep_schedule" AS S
LEFT JOIN "main"."main_prep"."prep_team_ratings" V ON V.team_long = S.visitorneutral
LEFT JOIN "main"."main_prep"."prep_team_ratings" H ON H.team_long = S.homeneutral
WHERE S.type = 'reg_season'
GROUP BY ALL
UNION ALL
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
FROM "main"."main_prep"."prep_schedule" AS S
WHERE S.type <> 'reg_season'
GROUP BY ALL