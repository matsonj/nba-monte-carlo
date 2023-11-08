SELECT
    game_date AS date,
    CASE WHEN type = 'tournament' THEN '🏆' ELSE '' END AS "T",
    vstm AS visiting_team,
    '@' AS " ",
    hmtm AS home_team,
    CASE 
        WHEN home_team_score > visiting_team_score THEN home_team_score || ' - ' || visiting_team_score 
        ELSE visiting_team_score || ' - ' || home_team_score
    END AS score,
    winning_team,
    ABS(elo_change) AS elo_change_num1,
    type
FROM nba_results_log RL
ORDER BY game_date desc