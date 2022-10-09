
  create view "main"."reg_season_summary__dbt_tmp" as (
    

SELECT winning_team as team,
  E.conf,
  R.elo_rating,
  ROUND(AVG(wins),1) AS avg_wins,
  R.win_total as vegas_wins,
  ROUND(AVG(R.win_total) - AVG(wins),1) as elo_vs_vegas,
  ROUND(PERCENTILE_CONT(0.05) within group (order by wins asc),1) as wins_5th,
  ROUND(PERCENTILE_CONT(0.95) within group (order by wins asc),1) as wins_95th,
  COUNT(*) FILTER (WHERE made_playoffs = 1 AND made_play_in = 0) as made_playoffs,
  COUNT(*) FILTER (WHERE made_play_in = 1) as made_play_in,
  ROUND(PERCENTILE_CONT(0.05) within group (order by season_rank asc),1) as seed_5th,
  ROUND(AVG(season_rank),1) AS avg_seed,
  ROUND(PERCENTILE_CONT(0.95) within group (order by season_rank asc),1) as seed_95th
FROM "main"."main"."reg_season_end" E 
  LEFT JOIN "main"."main"."ratings" R ON R.team = E.winning_team
GROUP BY ALL
  );
