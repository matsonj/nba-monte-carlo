

  create  table
    "main"."vegas_wins__dbt_tmp"
  as (
    

SELECT team,
    win_total
FROM "main"."main"."raw_team_ratings" S
GROUP BY ALL
  );

