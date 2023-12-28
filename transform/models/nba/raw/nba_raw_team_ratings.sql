SELECT *
FROM {{ source( 'nba', 'nba_team_ratings' ) }}
