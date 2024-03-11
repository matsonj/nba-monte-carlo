MODEL (
  name nba.post_season_schedule,
  kind VIEW
);

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
FROM nba.prep_schedule AS S
WHERE S.type <> 'reg_season'
GROUP BY ALL;
