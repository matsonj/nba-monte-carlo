
  create view "main_main"."vegas_wins__dbt_tmp" as (
    

SELECT
    team,
    win_total
FROM "main"."main_prep"."prep_team_ratings"
GROUP BY ALL
  );
