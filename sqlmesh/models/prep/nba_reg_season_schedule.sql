MODEL (
  name nba.reg_season_schedule,
  kind VIEW
);

SELECT
    S.id AS game_id,
    S.date as date,
    CASE WHEN s.notes = 'In-Season Tournament' THEN 'tournament' 
        WHEN s.notes = 'Knockout Rounds' THEN 'knockout'
        ELSE 'reg_season' END 
    AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    COALESCE(R.visiting_team_elo_rating,V.elo_rating::int) AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    COALESCE(R.home_team_elo_rating,H.elo_rating::int) AS home_team_elo_rating
FROM nba.prep_schedule AS S
LEFT JOIN nba.ratings V ON V.team_long = S.VisTm
LEFT JOIN nba.ratings H ON H.team_long = S.HomeTm
LEFT JOIN nba.elo_rollforward R ON R.game_id = S.id
WHERE S.type = 'reg_season' 
GROUP BY ALL;