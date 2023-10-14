WITH home_rating AS (
    SELECT home_team as team
    , max(game_id) game_id
    , max_by(home_team_elo_rating - elo_change, game_id) elo_rating
    FROM {{ ref('nfl_elo_rollforward') }}
    GROUP BY ALL
),
visiting_rating AS (
    SELECT visiting_team as team
    , max(game_id) game_id
    , max_by(visiting_team_elo_rating + elo_change, game_id) elo_rating
    FROM {{ ref('nfl_elo_rollforward') }}
    GROUP BY ALL
),
union_rating AS (
    SELECT * FROM home_rating
    UNION ALL
    SELECT * FROM visiting_rating
),
final_rating AS (
    SELECT team, max_by(elo_rating, game_id) AS elo_rating
    FROM union_rating
    GROUP BY ALL
)
SELECT f.team
, f.elo_rating AS elo_rating
, o.elo_rating AS original_rating
, {{ var('latest_ratings') }} AS latest_ratings
FROM final_rating f
INNER JOIN {{ ref('nfl_raw_team_ratings') }} o ON f.team = o.team