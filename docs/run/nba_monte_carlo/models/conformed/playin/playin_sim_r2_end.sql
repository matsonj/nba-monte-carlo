
  create view "main"."playin_sim_r2_end__dbt_tmp" as (
    

SELECT
    P1.scenario_id,
    P1.conf,
    P1.winning_team,
    P1.conf || '-7' AS seed,
    P1.winning_team_elo_rating
FROM "main"."main"."playin_sim_r1_end" P1
WHERE P1.result = 'winner advance'
UNION ALL
SELECT
    P2.scenario_id,
    P2.conf AS conf,
    P2.winning_team,
    P2.conf || '-8' AS seed,
    CASE
        WHEN P2.winning_team = P2.home_team THEN P2.home_team_elo_rating
        ELSE P2.visiting_team_elo_rating
    END AS elo_rating
FROM "main"."main"."playin_sim_r2" P2
  );
