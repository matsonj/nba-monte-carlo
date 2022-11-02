
  create view "main"."vegas_wins__dbt_tmp" as (
    SELECT
    team,
    win_total
FROM "main"."main"."ratings"
GROUP BY ALL
  );
