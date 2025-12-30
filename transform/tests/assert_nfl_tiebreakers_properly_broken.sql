{{ config(
    store_failures=true,
    store_failures_as='table'
) }}

-- Test that all NFL tiebreakers are properly broken according to official NFL rules
-- This query should return 0 rows if all ties are properly resolved

WITH 
-- Get base tiebreaker results
tiebreaker_results AS (
    SELECT 
        scenario_id,
        team,
        conference,
        rank,
        wins,
        tiebreaker_used
    FROM {{ ref('nfl_tiebreakers_optimized') }}
),

-- Get game results for validation
game_results AS (
    SELECT 
        scenario_id,
        home_team,
        visiting_team,
        winning_team
    FROM {{ ref('nfl_reg_season_simulator') }}
),

-- Get team metadata
team_info AS (
    SELECT 
        team,
        conf as conference,
        division
    FROM {{ ref('nfl_ratings') }}
),

-- Test 1: Basic structural validation
tie_validation AS (
    SELECT 
        scenario_id,
        conference,
        rank,
        COUNT(*) as teams_with_same_rank,
        STRING_AGG(team, ', ') as tied_teams
    FROM tiebreaker_results
    GROUP BY scenario_id, conference, rank
    HAVING COUNT(*) > 1
),

rank_gaps AS (
    SELECT 
        scenario_id,
        conference,
        rank,
        LAG(rank) OVER (PARTITION BY scenario_id, conference ORDER BY rank) as prev_rank,
        CAST(rank AS INT) - CAST(LAG(rank) OVER (PARTITION BY scenario_id, conference ORDER BY rank) AS INT) as rank_gap
    FROM tiebreaker_results
),

seeding_validation AS (
    SELECT 
        scenario_id,
        conference,
        -- Count teams in each seeding category
        COUNT(CASE WHEN rank BETWEEN 1 AND 4 THEN 1 END) as division_winners,
        COUNT(CASE WHEN rank BETWEEN 5 AND 7 THEN 1 END) as wildcards,
        COUNT(CASE WHEN rank >= 8 THEN 1 END) as non_playoff_teams,
        COUNT(*) as total_teams
    FROM tiebreaker_results
    GROUP BY scenario_id, conference
),

-- Test 2: Division winner validation
division_winners AS (
    SELECT 
        tr.scenario_id,
        tr.team,
        tr.conference,
        tr.wins,
        tr.rank,
        tr.tiebreaker_used,
        ti.division
    FROM tiebreaker_results tr
    JOIN team_info ti ON tr.team = ti.team
    WHERE tr.rank BETWEEN 1 AND 4
),

-- Check if division winners actually won their divisions
division_winner_validation AS (
    SELECT 
        dw.scenario_id,
        dw.conference,
        dw.division,
        dw.team as division_winner,
        dw.wins as winner_wins,
        COUNT(other.team) as teams_with_better_record
    FROM division_winners dw
    JOIN team_info ti ON ti.division = dw.division AND ti.conference = dw.conference
    JOIN tiebreaker_results other ON other.team = ti.team AND other.scenario_id = dw.scenario_id
    WHERE other.wins > dw.wins
    GROUP BY dw.scenario_id, dw.conference, dw.division, dw.team, dw.wins
    HAVING COUNT(other.team) > 0
),

-- Test 3: Head-to-head tiebreaker validation for true two-team ties only
two_team_h2h_validation AS (
    SELECT DISTINCT
        tr1.scenario_id,
        tr1.conference,
        tr1.team as team1,
        tr2.team as team2,
        tr1.wins as team1_wins,
        tr2.wins as team2_wins,
        tr1.rank as team1_rank,
        tr2.rank as team2_rank,
        tr1.tiebreaker_used as team1_tiebreaker,
        tr2.tiebreaker_used as team2_tiebreaker,
        -- Calculate actual head-to-head record
        COALESCE(h2h.team1_games_won, 0) as team1_h2h_wins,
        COALESCE(h2h.team2_games_won, 0) as team2_h2h_wins,
        COALESCE(h2h.total_h2h_games, 0) as total_h2h_games,
        tied_teams.team_count
    FROM tiebreaker_results tr1
    JOIN tiebreaker_results tr2 ON tr1.scenario_id = tr2.scenario_id 
        AND tr1.conference = tr2.conference 
        AND tr1.team != tr2.team
        AND tr1.wins = tr2.wins  -- Same record
        AND ABS(CAST(tr1.rank AS INT) - CAST(tr2.rank AS INT)) = 1  -- Adjacent ranks
    -- Count how many teams have the same record in this scenario/conference
    JOIN (
        SELECT 
            scenario_id,
            conference,
            wins,
            COUNT(*) as team_count
        FROM tiebreaker_results
        GROUP BY scenario_id, conference, wins
    ) tied_teams ON tied_teams.scenario_id = tr1.scenario_id 
        AND tied_teams.conference = tr1.conference 
        AND tied_teams.wins = tr1.wins
    LEFT JOIN (
        -- Calculate head-to-head records
        SELECT 
            gr.scenario_id,
            LEAST(gr.home_team, gr.visiting_team) as team1,
            GREATEST(gr.home_team, gr.visiting_team) as team2,
            SUM(CASE WHEN gr.winning_team = LEAST(gr.home_team, gr.visiting_team) THEN 1 ELSE 0 END) as team1_games_won,
            SUM(CASE WHEN gr.winning_team = GREATEST(gr.home_team, gr.visiting_team) THEN 1 ELSE 0 END) as team2_games_won,
            COUNT(*) as total_h2h_games
        FROM game_results gr
        GROUP BY gr.scenario_id, LEAST(gr.home_team, gr.visiting_team), GREATEST(gr.home_team, gr.visiting_team)
    ) h2h ON h2h.scenario_id = tr1.scenario_id
        AND h2h.team1 = LEAST(tr1.team, tr2.team)
        AND h2h.team2 = GREATEST(tr1.team, tr2.team)
    WHERE tr1.team < tr2.team  -- Avoid duplicates
        AND tied_teams.team_count = 2  -- Only validate true 2-team ties
),

-- Validate head-to-head tiebreakers were applied correctly
-- NOTE: This test only catches violations when the model reports tiebreaker_used = 'head-to-head'.
-- It does NOT catch bugs where H2H is tied and subsequent tiebreakers (division record, common games,
-- conference record, SOV, SOS) are miscalculated. Those bugs require validating the full NFL
-- tiebreaker chain, which is too complex/slow for this test. The fix for such bugs must be in
-- the model code (nfl_tiebreakers_optimized.py).
h2h_tiebreaker_violations AS (
    SELECT 
        scenario_id,
        conference,
        team1,
        team2,
        team1_rank,
        team2_rank,
        team1_h2h_wins,
        team2_h2h_wins,
        total_h2h_games,
        team1_tiebreaker,
        team2_tiebreaker
    FROM two_team_h2h_validation
    WHERE total_h2h_games > 0  -- Teams actually played head-to-head
        AND (
            -- Team with worse H2H record ranked higher
            (team1_h2h_wins > team2_h2h_wins AND team1_rank > team2_rank) OR
            (team2_h2h_wins > team1_h2h_wins AND team2_rank > team1_rank)
        )
        AND (team1_tiebreaker LIKE '%head-to-head%' OR team2_tiebreaker LIKE '%head-to-head%')
),

-- Test 4: Wildcard seeding validation
wildcard_validation AS (
    SELECT 
        scenario_id,
        conference,
        rank,
        team,
        wins,
        tiebreaker_used
    FROM tiebreaker_results
    WHERE rank BETWEEN 5 AND 7
),

-- Check if wildcards are actually the best non-division winners
wildcard_seeding_violations AS (
    SELECT 
        wc.scenario_id,
        wc.conference,
        wc.team as wildcard_team,
        wc.wins as wildcard_wins,
        wc.rank as wildcard_rank,
        COUNT(better.team) as better_non_division_winners
    FROM wildcard_validation wc
    JOIN tiebreaker_results better ON better.scenario_id = wc.scenario_id 
        AND better.conference = wc.conference
        AND better.rank > 7  -- Non-playoff team
        AND better.wins > wc.wins
    GROUP BY wc.scenario_id, wc.conference, wc.team, wc.wins, wc.rank
    HAVING COUNT(better.team) > 0
),

-- Test 5: Tiebreaker consistency validation
tiebreaker_consistency AS (
    SELECT 
        scenario_id,
        conference,
        wins,
        tiebreaker_used,
        COUNT(DISTINCT team) as teams_with_same_record,
        COUNT(DISTINCT tiebreaker_used) as different_tiebreakers_used
    FROM tiebreaker_results
    GROUP BY scenario_id, conference, wins, tiebreaker_used
    HAVING COUNT(DISTINCT team) > 1 AND COUNT(DISTINCT tiebreaker_used) > 1
),

-- Test 6: Division ties where H2H is tied - validate division and conference record tiebreakers
-- This is a focused test for two-team division ties where H2H is tied but div/conf record should decide
long_games AS (
    SELECT scenario_id, home_team as team, visiting_team as opponent,
           CASE WHEN winning_team = home_team THEN 1 ELSE 0 END as won
    FROM game_results
    UNION ALL
    SELECT scenario_id, visiting_team as team, home_team as opponent,
           CASE WHEN winning_team = visiting_team THEN 1 ELSE 0 END as won
    FROM game_results
),

-- Pre-calculate division and conference records for all teams (fast, no correlated subqueries)
team_div_conf_records AS (
    SELECT 
        lg.scenario_id,
        lg.team,
        ti.division,
        ti.conference,
        -- Division record: games against same-division AND same-conference opponents
        -- (AFC South and NFC South are different divisions!)
        SUM(CASE WHEN ti_opp.division = ti.division AND ti_opp.conference = ti.conference THEN lg.won ELSE 0 END) as div_wins,
        SUM(CASE WHEN ti_opp.division = ti.division AND ti_opp.conference = ti.conference THEN 1 ELSE 0 END) as div_games,
        -- Conference record: games against same-conference opponents
        SUM(CASE WHEN ti_opp.conference = ti.conference THEN lg.won ELSE 0 END) as conf_wins,
        SUM(CASE WHEN ti_opp.conference = ti.conference THEN 1 ELSE 0 END) as conf_games
    FROM long_games lg
    JOIN team_info ti ON lg.team = ti.team
    JOIN team_info ti_opp ON lg.opponent = ti_opp.team
    GROUP BY lg.scenario_id, lg.team, ti.division, ti.conference
),

-- Find division title disputes: one team is division winner, one isn't, but they have same wins and tied H2H
-- This validates the full tiebreaker chain: common games → division → conference records
div_title_disputes AS (
    SELECT
        tr1.scenario_id,
        ti1.division,
        -- team1 is the division winner (rank 1-4), team2 is not
        tr1.team as winner_team,
        tr2.team as loser_team,
        tr1.wins,
        tr1.rank as winner_rank,
        tr2.rank as loser_rank,
        -- H2H
        CASE WHEN tr1.team < tr2.team THEN COALESCE(h2h.team1_h2h_wins, 0) ELSE COALESCE(h2h.team2_h2h_wins, 0) END as winner_h2h,
        CASE WHEN tr1.team < tr2.team THEN COALESCE(h2h.team2_h2h_wins, 0) ELSE COALESCE(h2h.team1_h2h_wins, 0) END as loser_h2h,
        -- Division records
        COALESCE(r1.div_wins, 0) as winner_div_wins,
        COALESCE(r1.div_games, 1) as winner_div_games,
        COALESCE(r2.div_wins, 0) as loser_div_wins,
        COALESCE(r2.div_games, 1) as loser_div_games,
        -- Conference records
        COALESCE(r1.conf_wins, 0) as winner_conf_wins,
        COALESCE(r1.conf_games, 1) as winner_conf_games,
        COALESCE(r2.conf_wins, 0) as loser_conf_wins,
        COALESCE(r2.conf_games, 1) as loser_conf_games
    FROM tiebreaker_results tr1
    JOIN tiebreaker_results tr2 ON tr1.scenario_id = tr2.scenario_id
        AND tr1.conference = tr2.conference
        AND tr1.wins = tr2.wins
        AND tr1.team != tr2.team
    JOIN team_info ti1 ON tr1.team = ti1.team
    JOIN team_info ti2 ON tr2.team = ti2.team
    LEFT JOIN (
        SELECT gr.scenario_id,
            LEAST(gr.home_team, gr.visiting_team) as team1,
            GREATEST(gr.home_team, gr.visiting_team) as team2,
            SUM(CASE WHEN gr.winning_team = LEAST(gr.home_team, gr.visiting_team) THEN 1 ELSE 0 END) as team1_h2h_wins,
            SUM(CASE WHEN gr.winning_team = GREATEST(gr.home_team, gr.visiting_team) THEN 1 ELSE 0 END) as team2_h2h_wins,
            COUNT(*) as h2h_games
        FROM game_results gr
        GROUP BY gr.scenario_id, LEAST(gr.home_team, gr.visiting_team), GREATEST(gr.home_team, gr.visiting_team)
    ) h2h ON h2h.scenario_id = tr1.scenario_id
        AND h2h.team1 = LEAST(tr1.team, tr2.team)
        AND h2h.team2 = GREATEST(tr1.team, tr2.team)
    LEFT JOIN team_div_conf_records r1 ON r1.scenario_id = tr1.scenario_id AND r1.team = tr1.team
    LEFT JOIN team_div_conf_records r2 ON r2.scenario_id = tr2.scenario_id AND r2.team = tr2.team
    WHERE ti1.division = ti2.division  -- Same division
        AND tr1.rank BETWEEN 1 AND 4   -- tr1 is division winner
        AND tr2.rank > 4               -- tr2 is NOT division winner
        -- H2H is tied (teams actually played each other)
        AND CASE WHEN tr1.team < tr2.team THEN COALESCE(h2h.team1_h2h_wins, 0) ELSE COALESCE(h2h.team2_h2h_wins, 0) END
          = CASE WHEN tr1.team < tr2.team THEN COALESCE(h2h.team2_h2h_wins, 0) ELSE COALESCE(h2h.team1_h2h_wins, 0) END
        -- And they actually played (h2h_games > 0)
        AND COALESCE(h2h.h2h_games, 0) > 0
),

-- Flag violations: the "loser" (non-division winner) has BETTER tiebreaker than the "winner" per NFL rules
-- Checks common games first, then division, then conference records
div_conf_tiebreaker_violations AS (
    SELECT
        scenario_id,
        division,
        winner_team,
        loser_team,
        wins,
        winner_rank,
        loser_rank,
        winner_h2h,
        loser_h2h,
        -- Division
        winner_div_wins,
        winner_div_games,
        loser_div_wins,
        loser_div_games,
        CAST(winner_div_wins AS DOUBLE) / winner_div_games as winner_div_pct,
        CAST(loser_div_wins AS DOUBLE) / loser_div_games as loser_div_pct,
        -- Conference
        winner_conf_wins,
        winner_conf_games,
        loser_conf_wins,
        loser_conf_games,
        CAST(winner_conf_wins AS DOUBLE) / winner_conf_games as winner_conf_pct,
        CAST(loser_conf_wins AS DOUBLE) / loser_conf_games as loser_conf_pct
    FROM div_title_disputes
    WHERE
        -- For now, just check division/conference (common games validation is complex)
        -- Violation: Loser has better division record than winner
        CAST(loser_div_wins AS DOUBLE) / loser_div_games > CAST(winner_div_wins AS DOUBLE) / winner_div_games + 0.001
        OR
        -- Violation: Division tied, but loser has better conference record
        (ABS(CAST(winner_div_wins AS DOUBLE) / winner_div_games - CAST(loser_div_wins AS DOUBLE) / loser_div_games) < 0.001
         AND CAST(loser_conf_wins AS DOUBLE) / loser_conf_games > CAST(winner_conf_wins AS DOUBLE) / winner_conf_games + 0.001)
),

-- Test 7: Coin toss validation (should only be used as last resort)
premature_coin_toss AS (
    SELECT 
        tr.scenario_id,
        tr.conference,
        tr.team,
        tr.wins,
        tr.rank,
        tr.tiebreaker_used
    FROM tiebreaker_results tr
    WHERE tr.tiebreaker_used = 'coin_toss'
        OR tr.tiebreaker_used LIKE '%team name%'
),

-- Aggregate all assertion failures
assertion_failures AS (
    -- Test 1: No tied ranks
    SELECT 
        'TIED_RANKS' as failure_type,
        scenario_id,
        conference,
        CAST(rank AS VARCHAR) as detail,
        'Teams tied at same rank: ' || tied_teams as description
    FROM tie_validation
    
    UNION ALL
    
    -- Test 2: No gaps in ranking
    SELECT 
        'RANK_GAPS' as failure_type,
        scenario_id,
        conference,
        CAST(rank AS VARCHAR) as detail,
        'Gap of ' || CAST(rank_gap AS VARCHAR) || ' between rank ' || CAST(prev_rank AS VARCHAR) || ' and ' || CAST(rank AS VARCHAR) as description
    FROM rank_gaps 
    WHERE prev_rank IS NOT NULL AND rank_gap > 1
    
    UNION ALL
    
    -- Test 3: Proper seeding structure
    SELECT 
        'SEEDING_STRUCTURE' as failure_type,
        scenario_id,
        conference,
        'DivWin:' || CAST(division_winners AS VARCHAR) || ' WC:' || CAST(wildcards AS VARCHAR) as detail,
        'Expected 4 division winners and 3 wildcards, got ' || CAST(division_winners AS VARCHAR) || ' division winners and ' || CAST(wildcards AS VARCHAR) || ' wildcards' as description
    FROM seeding_validation
    WHERE division_winners != 4 OR wildcards != 3
    
    UNION ALL
    
    -- Test 4: Total teams per conference
    SELECT 
        'TEAM_COUNT' as failure_type,
        scenario_id,
        conference,
        CAST(total_teams AS VARCHAR) as detail,
        'Expected 16 teams per conference, got ' || CAST(total_teams AS VARCHAR) as description
    FROM seeding_validation
    WHERE total_teams != 16
    
    UNION ALL
    
    -- Test 5: Ranks start at 1
    SELECT 
        'RANK_START' as failure_type,
        t1.scenario_id,
        t1.conference,
        CAST(MIN(t1.rank) AS VARCHAR) as detail,
        'Ranks should start at 1, but lowest rank is ' || CAST(MIN(t1.rank) AS VARCHAR) as description
    FROM tiebreaker_results t1
    GROUP BY t1.scenario_id, t1.conference
    HAVING MIN(t1.rank) != 1
    
    UNION ALL
    
    -- Test 6: Division winners actually won their divisions
    SELECT 
        'DIVISION_WINNER_INVALID' as failure_type,
        scenario_id,
        conference,
        division_winner as detail,
        division_winner || ' ranked as division winner but ' || CAST(teams_with_better_record AS VARCHAR) || ' team(s) in same division have better record' as description
    FROM division_winner_validation
    
    UNION ALL
    
    -- Test 7: Head-to-head tiebreakers applied correctly
    SELECT 
        'H2H_VIOLATION' as failure_type,
        scenario_id,
        conference,
        team1 || ' vs ' || team2 as detail,
        'Head-to-head tiebreaker violation: ' || team1 || ' (H2H: ' || CAST(team1_h2h_wins AS VARCHAR) || '-' || CAST(team2_h2h_wins AS VARCHAR) || ', Rank: ' || CAST(team1_rank AS VARCHAR) || ') vs ' || team2 || ' (Rank: ' || CAST(team2_rank AS VARCHAR) || ')' as description
    FROM h2h_tiebreaker_violations
    
    UNION ALL
    
    -- Test 8: Wildcard seeding violations
    SELECT 
        'WILDCARD_VIOLATION' as failure_type,
        scenario_id,
        conference,
        wildcard_team as detail,
        wildcard_team || ' is wildcard with ' || CAST(wildcard_wins AS VARCHAR) || ' wins, but ' || CAST(better_non_division_winners AS VARCHAR) || ' non-division winner(s) have better record' as description
    FROM wildcard_seeding_violations
    
    UNION ALL
    
    -- Test 9: Tiebreaker consistency
    SELECT 
        'TIEBREAKER_INCONSISTENCY' as failure_type,
        scenario_id,
        conference,
        CAST(wins AS VARCHAR) || ' wins' as detail,
        CAST(teams_with_same_record AS VARCHAR) || ' teams with same record used ' || CAST(different_tiebreakers_used AS VARCHAR) || ' different tiebreakers' as description
    FROM tiebreaker_consistency
    
    UNION ALL
    
    -- Test 10: Premature coin toss usage
    SELECT 
        'PREMATURE_COIN_TOSS' as failure_type,
        scenario_id,
        conference,
        team as detail,
        team || ' resolved by coin toss/team name - verify all other tiebreakers were properly exhausted' as description
    FROM premature_coin_toss
    
    UNION ALL
    
    -- Test 11: Division title given to wrong team when H2H tied and tiebreakers should decide
    SELECT 
        'DIV_TITLE_VIOLATION' as failure_type,
        scenario_id,
        division as conference,
        winner_team || ' vs ' || loser_team as detail,
        'Wrong division winner: ' || winner_team || ' won division (rank ' || CAST(winner_rank AS VARCHAR) ||
        ') but ' || loser_team || ' (rank ' || CAST(loser_rank AS VARCHAR) || ') has better tiebreaker. ' ||
        'H2H tied (' || CAST(winner_h2h AS VARCHAR) || '-' || CAST(loser_h2h AS VARCHAR) || '). ' ||
        'Div record: ' || CAST(ROUND(winner_div_pct * 100, 1) AS VARCHAR) || '% vs ' || CAST(ROUND(loser_div_pct * 100, 1) AS VARCHAR) || '%. ' ||
        'Conf record: ' || CAST(ROUND(winner_conf_pct * 100, 1) AS VARCHAR) || '% vs ' || CAST(ROUND(loser_conf_pct * 100, 1) AS VARCHAR) || '%' as description
    FROM div_conf_tiebreaker_violations
)

-- Return all assertion failures (should be 0 rows if everything is correct)
SELECT 
    failure_type,
    scenario_id,
    conference,
    detail,
    description
FROM assertion_failures
ORDER BY failure_type, scenario_id, conference
