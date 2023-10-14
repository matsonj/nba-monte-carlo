SELECT *
FROM {{ source( 'nfl', 'nfl_team_ratings' ) }}
