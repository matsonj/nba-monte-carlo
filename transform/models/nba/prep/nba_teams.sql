SELECT
    R.team_long,
    R.team
FROM {{ ref( 'nba_ratings' ) }} R