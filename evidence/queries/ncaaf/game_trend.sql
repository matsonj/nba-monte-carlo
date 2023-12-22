
with cte_games AS (
SELECT 0 as game_id, team, original_rating as elo_rating, 0 as elo_change 
FROM src_ncaaf_ratings
UNION ALL
SELECT game_id, visiting_team as team, visiting_team_elo_rating as elo_rating, elo_change
FROM src_ncaaf_elo_rollforward
UNION ALL
SELECT game_id, home_team as team, home_team_elo_rating as elo_rating, elo_change*-1 as elo_change
FROM src_ncaaf_elo_rollforward
 )
SELECT 
    COALESCE(AR.week_number,0) AS week,
    RL.team,
    RL.elo_rating, 
    RL.elo_change,
    sum(RL.elo_change) over (partition by team order by COALESCE(AR.Week_number,0) asc rows between unbounded preceding and current row) as cumulative_elo_change_num0
FROM cte_games RL
LEFT JOIN src_ncaaf_schedules AR ON
    AR.game_id = RL.game_id