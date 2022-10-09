with  __dbt__cte__playoff_sim_r1_end as (


SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed
FROM "main"."main"."playoff_sim_r1" E
    LEFT JOIN "main"."main"."xf_series_to_seed" XF ON XF.series_id = E.series_id
WHERE E.series_result = 4
),  __dbt__cte__playoff_sim_r2_end as (


SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed
FROM "main"."main"."playoff_sim_r2" E
    LEFT JOIN "main"."main"."xf_series_to_seed" XF ON XF.series_id = E.series_id
WHERE E.series_result = 4
),  __dbt__cte__playoff_sim_r3_end as (


SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    XF.seed
FROM "main"."main"."playoff_sim_r3" E
    LEFT JOIN "main"."main"."xf_series_to_seed" XF ON XF.series_id = E.series_id
WHERE E.series_result = 4
),  __dbt__cte__playoff_sim_r4_end as (


SELECT E.scenario_id,
    E.series_id,
    E.game_id,
    E.winning_team,
    CASE WHEN E.winning_team = E.home_team THEN E.home_team_elo_rating
        ELSE E.visiting_team_elo_rating
    END AS elo_rating,
    'champ' AS seed
FROM "main"."main"."playoff_sim_r4" E
WHERE E.series_result = 4
),cte_playoffs_r1 AS (
    SELECT winning_team,
        COUNT(1) AS made_playoffs
    FROM "main"."main"."initialize_seeding"
    GROUP BY ALL
),
cte_playoffs_r2 AS (
    SELECT winning_team,
        COUNT(1) AS made_conf_semis
    FROM __dbt__cte__playoff_sim_r1_end
    GROUP BY ALL
),
cte_playoffs_r3 AS (
        SELECT winning_team,
        COUNT(1) AS made_conf_finals
    FROM __dbt__cte__playoff_sim_r2_end
    GROUP BY ALL
),
cte_playoffs_r4 AS (
        SELECT winning_team,
        COUNT(1) AS made_finals
    FROM __dbt__cte__playoff_sim_r3_end
    GROUP BY ALL
),
cte_playoffs_finals AS (
        SELECT winning_team,
        COUNT(1) AS won_finals
    FROM __dbt__cte__playoff_sim_r4_end
    GROUP BY ALL
)

SELECT T.team,
    R1.made_playoffs,
    R2.made_conf_semis,
    R3.made_conf_finals,
    R4.made_finals,
    F.won_finals
FROM "main"."main"."teams" T
    LEFT JOIN cte_playoffs_r1 R1 ON R1.winning_team = T.team
    LEFT JOIN cte_playoffs_r2 R2 ON R2.winning_team = T.team
    LEFT JOIN cte_playoffs_r3 R3 ON R3.winning_team = T.team
    LEFT JOIN cte_playoffs_r4 R4 ON R4.winning_team = T.team
    LEFT JOIN cte_playoffs_finals F ON F.winning_team = T.team