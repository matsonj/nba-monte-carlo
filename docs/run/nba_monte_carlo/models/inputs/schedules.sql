

  create  table
    "main"."schedules__dbt_tmp"
  as (
    

SELECT S.key::int AS game_id,
    S.type,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM "main"."main"."raw_schedule" S
    LEFT JOIN "main"."main"."ratings" V ON V.team_long = S.visitorneutral
    LEFT JOIN "main"."main"."ratings" H ON H.team_long = S.homeneutral 
WHERE S.type = 'reg_season'
GROUP BY ALL
UNION ALL
SELECT S.key::int AS game_id,
    S.type,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM "main"."main"."raw_schedule" S
WHERE S.type <> 'reg_season'
GROUP BY ALL
  );

