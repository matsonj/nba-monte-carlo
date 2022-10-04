SELECT R.*,  
  MIN(wins) as min_wins, 
  PERCENTILE_CONT(0.05) within group (order by wins asc) as percentile_05,
  ROUND(AVG(wins),2) AS avg_wins,
  PERCENTILE_CONT(0.95) within group (order by wins asc) as percentile_95,
  MAX(wins) as max_wins, 
  ROUND(AVG(wins) - AVG(R.win_total),2) as model_vs_vegas 
FROM {{ ref( 'ratings' ) }} R
  LEFT JOIN {{ ref('reg_season_summary' ) }} S ON S.winning_team = R.team
GROUP BY ALL