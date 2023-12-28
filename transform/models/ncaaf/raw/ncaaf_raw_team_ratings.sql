SELECT *
FROM {{ source( 'ncaaf', 'ncaaf_team_ratings' ) }}
