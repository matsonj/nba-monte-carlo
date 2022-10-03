SELECT R.*, 
  ROUND(AVG(wins),2) AS avg_wins, 
  MIN(wins) as min_wins, 
  MAX(wins) as max_wins, 
  ROUND(AVG(wins) - AVG(R.win_total),2) as model_vs_vegas 
FROM {{ ref( 'ratings' ) }} R
  LEFT JOIN {{ ref('simulator_summary' ) }} S ON S.winning_team = R.team
GROUP BY ALL