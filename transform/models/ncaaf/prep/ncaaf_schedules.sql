SELECT
    S.id AS game_id,
    S.week as week_number,
    'reg_season' AS type,
    0 as series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    COALESCE(R.visiting_team_elo_rating,V.elo_rating::int) AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    COALESCE(R.home_team_elo_rating,H.elo_rating::int) AS home_team_elo_rating
FROM {{ ref( 'ncaaf_raw_schedule' ) }} AS S
LEFT JOIN {{ ref( 'ncaaf_ratings' ) }} V ON V.team = S.VisTm
LEFT JOIN {{ ref( 'ncaaf_ratings' ) }} H ON H.team = S.HomeTm
LEFT JOIN {{ ref( 'ncaaf_elo_rollforward' ) }} R ON R.game_id = S.id
GROUP BY ALL
/* -- EXCLUDING UNTIL I GET A PLAYOFFS MODULE FIGURED OUT
UNION ALL
SELECT
    *
FROM {{ ref( 'nba_post_season_schedule' ) }}
*/