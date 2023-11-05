SELECT
    R.team_long,
    R.team,
    tournament_group,
    conf
FROM {{ ref( 'nba_raw_team_ratings' ) }} R