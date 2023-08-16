SELECT
    *,
    {{ var('latest_ratings') }} AS latest_ratings
FROM  {{ source( 'nba_prep', 'elo_post' ) }}
