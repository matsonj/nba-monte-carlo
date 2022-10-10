-- get the winners from r1 and assign to seed 7
-- then union all and get winners from r2 and assign seed 8

SELECT P1.scenario_id,
    p1.conf,
    P1.winning_team,
    P1.conf || '-7' AS seed,
    P1.winning_team_elo_rating
FROM "main"."main"."playin_sim_r1_end" P1
WHERE P1.result = 'winner advance'
UNION ALL
SELECT P2.scenario_id,
    P2.conf AS conf,
    P2.winning_team,
    P2.conf || '-8' AS seed,
    CASE
        WHEN P2.winning_team = P2.home_team THEN P2.home_team_elo_rating
        ELSE P2.visiting_team_elo_rating
    END AS elo_rating
FROM "main"."main"."playin_sim_r2" P2