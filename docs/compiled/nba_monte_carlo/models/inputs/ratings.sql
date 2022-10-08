

SELECT team,
    team_long,
    conf,
    win_total,
    elo_rating::int as elo_rating
FROM "main"."main"."raw_team_ratings" S
GROUP BY ALL