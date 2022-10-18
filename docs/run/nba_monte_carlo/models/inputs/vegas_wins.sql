
  create view "main"."vegas_wins__dbt_tmp" as (
    





SELECT
    team,
    win_total

FROM "main"."main"."raw_team_ratings"

GROUP BY ALL
  );
