SELECT
    R.team_long,
    R.team
FROM {{ ref( 'nba_raw_team_ratings' ) }} R