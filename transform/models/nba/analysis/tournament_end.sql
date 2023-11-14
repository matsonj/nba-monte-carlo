WITH cte_wins AS (
    SELECT
        S.scenario_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_conf
            ELSE S.visiting_conf
        END AS conf,
        COUNT(*) AS wins
    FROM {{ ref( 'reg_season_simulator' ) }} S
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
        COUNT(*) AS losses
    FROM {{ ref( 'reg_season_simulator' ) }} S
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
        T.tournament_group
    FROM {{ ref( 'nba_teams') }} T 
    LEFT JOIN ( 
        SELECT I.generate_series AS scenario_id
        FROM generate_series(1, {{ var( 'scenarios' ) }} ) AS I) AS scenarios ON 1=1
    LEFT JOIN cte_wins W ON T.team = W.winning_team AND scenarios.scenario_id = W.scenario_id
    LEFT JOIN cte_losses L ON T.team = L.losing_team AND scenarios.scenario_id = L.scenario_id
),

cte_home_margin AS (
    SELECT
        T.Team,
        SUM(COALESCE(-H.actual_margin,-H.implied_line)) AS home_pt_diff
    FROM {{ ref( 'nba_teams') }} T 
    LEFT JOIN {{ ref( 'reg_season_predictions' ) }} H ON H.home_team = T.team AND H.type = 'tournament' AND H.winning_team = H.home_team
    GROUP BY ALL
),

cte_visitor_margin AS (
    SELECT
        T.Team,
        SUM(COALESCE(V.actual_margin,V.implied_line)) AS visitor_pt_diff
    FROM {{ ref( 'nba_teams') }} T 
    LEFT JOIN {{ ref( 'reg_season_predictions' ) }} V ON V.visiting_team = T.team AND V.type = 'tournament' AND V.winning_team = V.home_team
    GROUP BY ALL
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
        home_pt_diff + visitor_pt_diff AS pt_diff,
        --no tiebreaker, so however row number handles order ties will need to be dealt with
        ROW_NUMBER() OVER (PARTITION BY scenario_id, tournament_group ORDER BY wins DESC, pt_diff DESC ) AS group_rank
    FROM cte_results_with_group R
    LEFT JOIN cte_home_margin H ON H.team = R.winning_team
    LEFT JOIN cte_visitor_margin V ON V.team = R.winning_team

),

cte_wildcard AS (
    SELECT
        scenario_id,
        winning_team,
        conf,
        pt_diff,
        group_rank,
        ROW_NUMBER() OVER (PARTITION BY scenario_id, conf ORDER BY pt_diff DESC ) AS wildcard_rank
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
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM cte_made_tournament MP
LEFT JOIN {{ ref( 'nba_latest_elo' ) }} LE ON LE.team = MP.winning_team
