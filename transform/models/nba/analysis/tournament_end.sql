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

/* tiebreaking criteria: https://www.nba.com/news/in-season-tournament-101

  • Head-to-head record in the Group Stage;
  • Point differential in the Group Stage;
  • Total points scored in the Group Stage;
  • Regular season record from the 2022-23 NBA regular season; and
  • Random drawing (in the unlikely scenario that two or more teams are still tied following the previous tiebreakers).

*/

cte_ranked_wins AS (
    SELECT
        *,
        --no tiebreaker, so however row number handles order ties will need to be dealt with
        ROW_NUMBER() OVER (PARTITION BY scenario_id, tournament_group ORDER BY wins DESC, winning_team DESC ) AS season_rank
    FROM cte_results_with_group

),

cte_made_tournament AS (
    SELECT
        *,
        CASE
            WHEN season_rank = 1 THEN 1
            ELSE 0
        END AS made_tournament,
        CASE
            WHEN season_rank = 2 THEN 1
            ELSE 0
        END AS made_wildcard,
        tournament_group || '-' || season_rank::text AS seed
    FROM cte_ranked_wins
)

SELECT 
    MP.*,
    LE.elo_rating,
    {{ var( 'sim_start_game_id' ) }} AS sim_start_game_id
FROM cte_made_tournament MP
LEFT JOIN {{ ref( 'nba_latest_elo' ) }} LE ON LE.team = MP.winning_team
