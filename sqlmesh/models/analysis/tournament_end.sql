MODEL (
  name nba.tournament_end,
  kind FULL
);

@DEF(scenarios, 10000);

WITH cte_wins AS (
    SELECT
        S.scenario_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_conf
            ELSE S.visiting_conf
        END AS conf,
        COUNT(*) AS wins,
        SUM( CASE WHEN include_actuals = true THEN 1 ELSE 0 END) AS actual_wins
    FROM nba.reg_season_simulator S
    WHERE S.type = 'tournament'
    GROUP BY ALL
),

cte_losses AS (
    SELECT
        S.scenario_id,
        CASE WHEN S.home_team = S.winning_team 
            THEN S.visiting_team ELSE S.home_team
        END AS losing_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_conf
            ELSE S.home_conf
        END AS conf,
        COUNT(*) AS losses,
        SUM( CASE WHEN include_actuals = true THEN 1 ELSE 0 END) AS actual_losses
    FROM nba.reg_season_simulator S
    WHERE S.type = 'tournament'
    GROUP BY ALL
),

cte_results_with_group AS (
    SELECT 
        scenarios.scenario_id,
        T.team as winning_team,
        T.conf,
        COALESCE(W.wins,0) AS wins,
        COALESCE(L.losses,0) as losses,
        T.tournament_group,
        COALESCE(W.actual_wins,0) AS actual_wins,
        COALESCE(L.actual_losses,0) as actual_losses
    FROM nba.teams T 
    LEFT JOIN ( 
        SELECT I.generate_series AS scenario_id
        FROM generate_series(1, @scenarios ) AS I) AS scenarios ON 1=1
    LEFT JOIN cte_wins W ON T.team = W.winning_team AND scenarios.scenario_id = W.scenario_id
    LEFT JOIN cte_losses L ON T.team = L.losing_team AND scenarios.scenario_id = L.scenario_id
),

cte_home_margin AS (
    SELECT
        T.Team,
        COALESCE(SUM(COALESCE(-H.actual_margin,-H.implied_line)),0) AS home_pt_diff
    FROM nba.teams T 
    LEFT JOIN nba.reg_season_predictions H ON H.home_team = T.team AND H.type = 'tournament' 
        -- conditional join on reg season predictions
        AND CASE WHEN H.actual_margin IS NULL THEN H.winning_team = H.home_team ELSE 1=1 END
    GROUP BY ALL
),

cte_visitor_margin AS (
    SELECT
        T.Team,
        COALESCE(SUM(COALESCE(V.actual_margin,V.implied_line)),0) AS visitor_pt_diff
    FROM nba.teams T 
    LEFT JOIN nba.reg_season_predictions V ON V.visiting_team = T.team AND V.type = 'tournament'
        -- conditional join on reg season predictions
        AND CASE WHEN V.actual_margin IS NULL THEN V.winning_team = V.home_team ELSE 1=1 END
    GROUP BY ALL
),

cte_head_to_head AS (
    SELECT
        g.scenario_id,
        g.winning_team,
        CASE
            WHEN g.winning_team = g.home_team THEN g.visiting_team
            ELSE g.home_team
        END AS losing_team
    FROM nba.reg_season_simulator g
    WHERE type = 'tournament'
),

cte_head_to_head_wins AS (
    SELECT
        h.scenario_id,
        h.winning_team AS team,
        COUNT(*) AS h2h_wins
    FROM cte_head_to_head h
    INNER JOIN cte_wins w ON h.winning_team = w.winning_team AND h.scenario_id = w.scenario_id
        AND h.losing_team IN (
            SELECT winning_team 
            FROM cte_wins 
            WHERE wins = w.wins AND winning_team != w.winning_team
                AND scenario_id = w.scenario_id
        )
    GROUP BY ALL
),

cte_fuzz AS (
    SELECT
        R.scenario_id,
        R.winning_team,
        ((R.wins-R.actual_wins) * floor(random() * 5)) + ((R.losses-R.actual_losses) * floor(random() * -5)) AS fuzz
    FROM cte_results_with_group R
),

/* tiebreaking criteria: https://www.nba.com/news/in-season-tournament-101

  • Head-to-head record in the Group Stage;
  • Point differential in the Group Stage;
  • Total points scored in the Group Stage;
  • Regular season record from the 2022-23 NBA regular season; and
  • Random drawing (in the unlikely scenario that two or more teams are still tied following the previous tiebreakers).

*/

cte_ranked_wins AS (
    SELECT
        R.*,
        H2H.h2h_wins,
        -- fuzzing pt diff by scenario via brute force (7 pt swing either way)
        home_pt_diff + visitor_pt_diff + F.fuzz AS pt_diff,
        --no tiebreaker, so however row number handles order ties will need to be dealt with
        ROW_NUMBER() OVER (PARTITION BY R.scenario_id, tournament_group ORDER BY wins DESC, h2h_wins DESC, pt_diff DESC ) AS group_rank
    FROM cte_results_with_group R
    LEFT JOIN cte_home_margin H ON H.team = R.winning_team
    LEFT JOIN cte_visitor_margin V ON V.team = R.winning_team
    LEFT JOIN cte_head_to_head_wins H2H ON H2H.team = R.winning_team AND H2H.scenario_id = R.scenario_id
    LEFT JOIN cte_fuzz F ON F.scenario_id = R.scenario_id AND F.winning_team = R.winning_team
),

cte_wildcard AS (
    SELECT
        scenario_id,
        winning_team,
        conf,
        wins,
        pt_diff,
        group_rank,
        ROW_NUMBER() OVER (PARTITION BY scenario_id, conf ORDER BY wins DESC, pt_diff DESC, random() ) AS wildcard_rank
    FROM cte_ranked_wins R
    WHERE group_rank = 2
),

cte_made_tournament AS (
    SELECT
        W.*,
        CASE
            WHEN W.group_rank = 1 THEN 1
            ELSE 0
        END AS made_tournament,
        CASE
            WHEN WC.wildcard_rank = 1 AND WC.wildcard_rank IS NOT NULL THEN 1
            ELSE 0
        END AS made_wildcard,
        W.tournament_group || '-' || W.group_rank::text AS seed
    FROM cte_ranked_wins W
    LEFT JOIN cte_wildcard WC ON WC.winning_team = W.winning_team and WC.scenario_id = W.scenario_id
)

SELECT 
    MP.*,
    LE.elo_rating,
    0 AS sim_start_game_id
FROM cte_made_tournament MP
LEFT JOIN nba.latest_elo LE ON LE.team = MP.winning_team;
