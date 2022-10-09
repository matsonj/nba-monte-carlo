
  create view "main"."playoff_r1_end__dbt_tmp" as (
    SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    XF.seed
FROM "main"."main"."playoff_sim_r1" E
    LEFT JOIN "main"."main"."xf_series_to_seed" XF ON XF.series_id = E.series_id
WHERE E.series_result = 4
  );
