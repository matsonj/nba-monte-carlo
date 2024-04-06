MODEL (
  name nba.results_log,
  kind VIEW
);

WITH cte_avg_elo AS (
   SELECT AVG(elo_rating) AS elo_rating
   FROM nba.latest_elo
)
SELECT 
   RL.*, 
   A.elo_rating as Avg,
   CASE WHEN RL.visiting_team_elo_rating > RL.home_team_elo_rating 
      THEN RL.visiting_team ELSE RL.home_team END AS favored_team,
   CASE WHEN RL.visiting_team_elo_rating > A.elo_rating THEN 1 ELSE 0 END AS visiting_team_above_avg,
   CASE WHEN RL.home_team_elo_rating > A.elo_rating THEN 1 ELSE 0 END AS home_team_above_avg,
   CASE WHEN RL.winning_team = RL.home_team THEN RL.visiting_team ELSE RL.home_team END AS losing_team,
   LR.game_date,
   LR.home_team_score,
   LR.visiting_team_score,
   H.team AS hmTm,
   V.team AS VsTm,
   S.type
FROM  nba.elo_rollforward RL
LEFT JOIN cte_avg_elo A ON 1=1
LEFT JOIN nba.latest_results LR ON LR.game_id = RL.game_id
LEFT JOIN nba.teams H ON H.team_long = RL.home_team
LEFT JOIN nba.teams V ON V.team_long = RL.visiting_team 
LEFT JOIN nba.schedules S ON S.game_id = RL.game_id;