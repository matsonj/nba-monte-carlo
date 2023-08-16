SELECT *
FROM {{ source( 'nba', 'team_ratings' ) }}
