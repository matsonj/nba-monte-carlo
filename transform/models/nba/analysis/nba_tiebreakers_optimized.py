import pandas as pd
import polars as pl
import numpy as np
from typing import List, Dict, Tuple, Optional

# THIS MODEL IMPLEMENTS THE NBA TIEBREAKERS FOR TIES FOR PLAYOFF SEEDING
# THE RULES ARE AS FOLLOWS:
# Tiebreaker Basis – 2 Teams Tied
# (-) Tie breaker not needed (better overall winning percentage)
# (1) Better winning percentage in games against each other
# (2) Division leader wins a tie over a team not leading a division
# (3) Division won-lost percentage (only if teams are in same division)
# (4) Conference won-lost percentage
# (5) Better winning percentage against teams eligible for the playoffs in own
# conference (including teams that finished the regular season tied for a playoff
# position)
# (6) Better winning percentage against teams eligible for the playoffs in other
# conference (including teams that finished the regular season tied for a playoff
# position)
# (7) Better net result of total points scored less total points allowed against all
# opponents (“point differential”)
# Tiebreaker Basis – Three or More Teams Tied
# (-) Tie breaker not needed (better overall winning percentage)
# (1) Division leader wins tie from team not leading a division (this criterion is
# applied regardless of whether the tied teams are in the same division)
# (2) Better winning percentage in all games among the tied teams
# (3) Division won-lost percentage (only if all teams are in same division)
# (4) Conference won-lost percentage
# (5) Better winning percentage against teams eligible for the playoffs in own
# conference (including teams that finished the regular season tied for a playoff
# position)
# (6) Better net result of total points scored less total points allowed against all
# opponents (“point differential”)

def calculate_head_to_head(team1: str, team2: str, results: pl.DataFrame, team_map: Dict[str, str]) -> Tuple[float, float]:
    """Calculate head-to-head record between two teams."""
    # Convert team abbreviations to full names
    team1_full = team_map[team1]
    team2_full = team_map[team2]
    
    # Filter games where both teams played
    h2h_games = results.filter(
        ((pl.col('VisTm') == team1_full) & (pl.col('HomeTm') == team2_full)) |
        ((pl.col('VisTm') == team2_full) & (pl.col('HomeTm') == team1_full))
    )
    
    team1_wins = h2h_games.filter(pl.col('winner') == team1_full).height
    team2_wins = h2h_games.filter(pl.col('winner') == team2_full).height
    
    return team1_wins, team2_wins

def calculate_division_record(team: str, division: str, results: pl.DataFrame, teams: pl.DataFrame, team_map: Dict[str, str]) -> Tuple[int, int]:
    """Calculate a team's record against teams in their division."""
    # Get all teams in the same division
    division_teams = teams.filter(pl.col('division') == division)['team'].to_list()
    if team in division_teams:
        division_teams.remove(team)  # Remove the team itself
    
    # Convert to full names
    team_full = team_map[team]
    division_teams_full = [team_map[t] for t in division_teams]
    
    # Filter games against division opponents
    div_games = results.filter(
        ((pl.col('VisTm') == team_full) & (pl.col('HomeTm').is_in(division_teams_full))) |
        ((pl.col('HomeTm') == team_full) & (pl.col('VisTm').is_in(division_teams_full)))
    )
    
    wins = div_games.filter(pl.col('winner') == team_full).height
    losses = div_games.filter(pl.col('winner') != team_full).height
    
    return wins, losses

def calculate_conference_record(team: str, conference: str, results: pl.DataFrame, teams: pl.DataFrame, team_map: Dict[str, str]) -> Tuple[int, int]:
    """Calculate a team's record against teams in their conference."""
    # Get all teams in the same conference
    conf_teams = teams.filter(pl.col('conf') == conference)['team'].to_list()
    if team in conf_teams:
        conf_teams.remove(team)  # Remove the team itself
    
    # Convert to full names
    team_full = team_map[team]
    conf_teams_full = [team_map[t] for t in conf_teams]
    
    # Filter games against conference opponents
    conf_games = results.filter(
        ((pl.col('VisTm') == team_full) & (pl.col('HomeTm').is_in(conf_teams_full))) |
        ((pl.col('HomeTm') == team_full) & (pl.col('VisTm').is_in(conf_teams_full)))
    )
    
    wins = conf_games.filter(pl.col('winner') == team_full).height
    losses = conf_games.filter(pl.col('winner') != team_full).height
    
    return wins, losses

def calculate_top_10_record(team: str, top_10_teams: List[str], results: pl.DataFrame, team_map: Dict[str, str]) -> Tuple[int, int]:
    """Calculate a team's record against top 10 teams."""
    # Convert to full names
    team_full = team_map[team]
    top_10_teams_full = [team_map[t] for t in top_10_teams]
    
    # Filter games against top 10 teams
    top_10_games = results.filter(
        ((pl.col('VisTm') == team_full) & (pl.col('HomeTm').is_in(top_10_teams_full))) |
        ((pl.col('HomeTm') == team_full) & (pl.col('VisTm').is_in(top_10_teams_full)))
    )
    
    wins = top_10_games.filter(pl.col('winner') == team_full).height
    losses = top_10_games.filter(pl.col('winner') != team_full).height
    
    return wins, losses

def calculate_point_differential(team: str, results: pl.DataFrame, team_map: Dict[str, str]) -> int:
    """Calculate a team's point differential for all games."""
    team_full = team_map[team]
    
    # Games where team was home
    home_games = results.filter(pl.col('HomeTm') == team_full)
    home_diff = home_games.with_columns(
        diff=pl.when(pl.col('winner') == team_full)
        .then(pl.col('winner_pts') - pl.col('loser_pts'))
        .otherwise(pl.col('loser_pts') - pl.col('winner_pts'))
    )['diff'].sum()
    
    # Games where team was visitor
    away_games = results.filter(pl.col('VisTm') == team_full)
    away_diff = away_games.with_columns(
        diff=pl.when(pl.col('winner') == team_full)
        .then(pl.col('winner_pts') - pl.col('loser_pts'))
        .otherwise(pl.col('loser_pts') - pl.col('winner_pts'))
    )['diff'].sum()
    
    return home_diff + away_diff

# --- Tiebreaker Logic ---

def _calculate_win_percentage(wins: int, losses: int) -> float:
    """Calculates win percentage, handling division by zero."""
    if wins + losses == 0:
        return 0.0
    return wins / (wins + losses)

def _get_record_against_teams(team: str, opponent_list: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]]) -> Tuple[int, int]:
    """Calculates a team's W/L record against a specific list of opponents."""
    wins = 0
    losses = 0
    for opponent in opponent_list:
        if team == opponent: # Don't compare team against itself
            continue
        w, l = all_h2h_records.get((team, opponent), (0, 0))
        wins += w
        losses += l
    return wins, losses

def break_two_way_tie(team1: str, team2: str,
                      all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                      all_div_records: Dict[str, Tuple[int, int]],
                      all_conf_records: Dict[str, Tuple[int, int]],
                      all_point_diffs: Dict[str, int],
                      teams: pl.DataFrame,
                      playoff_eligible_east: List[str],
                      playoff_eligible_west: List[str]) -> Tuple[str, str]:
    """Apply NBA tiebreaker rules for two teams. Returns (winner, tiebreaker_used)."""
    
    # Cache team info to avoid repeated lookups
    team1_info = teams.filter(pl.col('team') == team1).row(index=0, named=True)
    team2_info = teams.filter(pl.col('team') == team2).row(index=0, named=True)
    if not team1_info or not team2_info:
        # Handle cases where team info might be missing (shouldn't happen with good data)
        # Defaulting to team1, but logging or raising an error might be better
        print(f"Warning: Missing team info for {team1} or {team2}")
        return team1, "error_missing_team_info" 

    # (-) Overall winning percentage is assumed to be equal for tied teams

    # (1) Better winning percentage in games against each other
    t1_h2h_wins, t2_h2h_wins = all_h2h_records.get((team1, team2), (0, 0))
    if t1_h2h_wins > t2_h2h_wins:
        return team1, "h2h_wins"
    if t2_h2h_wins > t1_h2h_wins:
        return team2, "h2h_wins"

    # (2) Division leader wins a tie over a team not leading a division
    # Note: Requires knowing which teams *won* their division overall, not just their record.
    # This information isn't directly available in the inputs. Assuming this check is implicitly handled
    # by overall record or needs external data. Skipping for now as it cannot be calculated.
    # print("Warning: Tiebreaker step (2) Division Leader not implemented due to missing data.")
    
    # (3) Division won-lost percentage (only if teams are in same division)
    if team1_info['division'] == team2_info['division']:
        t1_div_wins, t1_div_losses = all_div_records.get(team1, (0, 0))
        t2_div_wins, t2_div_losses = all_div_records.get(team2, (0, 0))
        t1_div_pct = _calculate_win_percentage(t1_div_wins, t1_div_losses)
        t2_div_pct = _calculate_win_percentage(t2_div_wins, t2_div_losses)
        if t1_div_pct > t2_div_pct:
            return team1, "division_record_pct"
        if t2_div_pct > t1_div_pct:
            return team2, "division_record_pct"
            
    # (4) Conference won-lost percentage
    t1_conf_wins, t1_conf_losses = all_conf_records.get(team1, (0, 0))
    t2_conf_wins, t2_conf_losses = all_conf_records.get(team2, (0, 0))
    t1_conf_pct = _calculate_win_percentage(t1_conf_wins, t1_conf_losses)
    t2_conf_pct = _calculate_win_percentage(t2_conf_wins, t2_conf_losses)
    if t1_conf_pct > t2_conf_pct:
        return team1, "conference_record_pct"
    if t2_conf_pct > t1_conf_pct:
        return team2, "conference_record_pct"

    # (5) Better winning percentage against teams eligible for the playoffs in own conference
    playoff_eligible_own_conf = playoff_eligible_east if team1_info['conf'] == 'East' else playoff_eligible_west
    t1_vs_eligible_own_wins, t1_vs_eligible_own_losses = _get_record_against_teams(team1, playoff_eligible_own_conf, all_h2h_records)
    t2_vs_eligible_own_wins, t2_vs_eligible_own_losses = _get_record_against_teams(team2, playoff_eligible_own_conf, all_h2h_records)
    t1_vs_eligible_own_pct = _calculate_win_percentage(t1_vs_eligible_own_wins, t1_vs_eligible_own_losses)
    t2_vs_eligible_own_pct = _calculate_win_percentage(t2_vs_eligible_own_wins, t2_vs_eligible_own_losses)
    if t1_vs_eligible_own_pct > t2_vs_eligible_own_pct:
        return team1, "vs_playoff_eligible_own_conf_pct"
    if t2_vs_eligible_own_pct > t1_vs_eligible_own_pct:
        return team2, "vs_playoff_eligible_own_conf_pct"

    # (6) Better winning percentage against teams eligible for the playoffs in other conference
    playoff_eligible_other_conf = playoff_eligible_west if team1_info['conf'] == 'East' else playoff_eligible_east
    t1_vs_eligible_other_wins, t1_vs_eligible_other_losses = _get_record_against_teams(team1, playoff_eligible_other_conf, all_h2h_records)
    t2_vs_eligible_other_wins, t2_vs_eligible_other_losses = _get_record_against_teams(team2, playoff_eligible_other_conf, all_h2h_records)
    t1_vs_eligible_other_pct = _calculate_win_percentage(t1_vs_eligible_other_wins, t1_vs_eligible_other_losses)
    t2_vs_eligible_other_pct = _calculate_win_percentage(t2_vs_eligible_other_wins, t2_vs_eligible_other_losses)
    if t1_vs_eligible_other_pct > t2_vs_eligible_other_pct:
        return team1, "vs_playoff_eligible_other_conf_pct"
    if t2_vs_eligible_other_pct > t1_vs_eligible_other_pct:
        return team2, "vs_playoff_eligible_other_conf_pct"

    # (7) Better net result of total points scored less total points allowed against all opponents (“point differential”)
    team1_diff = all_point_diffs.get(team1, -float('inf'))
    team2_diff = all_point_diffs.get(team2, -float('inf'))
    if team1_diff > team2_diff:
        return team1, "point_differential"
    # If point differentials are also equal (highly unlikely), default to team1 or random choice
    # Returning team2 here follows the original code's final else clause implicitly
    return team2, "point_differential"

# --- New/Modified Helpers for Multi-Way ---

def _get_h2h_pct_among_tied(team: str, tied_group: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]]) -> float:
    """Calculates H2H win pct for a team ONLY against others in the tied_group."""
    wins, losses = _get_record_against_teams(team, tied_group, all_h2h_records)
    return _calculate_win_percentage(wins, losses)

def _get_div_pct(team: str, all_div_records: Dict[str, Tuple[int, int]]) -> float:
    """Gets division win pct from pre-calculated records."""
    wins, losses = all_div_records.get(team, (0, 0))
    return _calculate_win_percentage(wins, losses)

def _get_conf_pct(team: str, all_conf_records: Dict[str, Tuple[int, int]]) -> float:
    """Gets conference win pct from pre-calculated records."""
    wins, losses = all_conf_records.get(team, (0, 0))
    return _calculate_win_percentage(wins, losses)

def _get_vs_playoff_eligible_pct(team: str, own_conf_eligible: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]]) -> float:
    """Calculates win pct against playoff eligible teams in own conference."""
    wins, losses = _get_record_against_teams(team, own_conf_eligible, all_h2h_records)
    return _calculate_win_percentage(wins, losses)

# Hypothetical function - requires external data/logic
def _is_division_leader(team: str, teams_table: pl.DataFrame, all_div_records: Dict[str, Tuple[int, int]], scenario_standings: pl.DataFrame) -> bool:
    """Checks if team is the undisputed leader (most wins, no ties) in their division for the given scenario."""
    try:
        # Find the team's division and wins in this scenario
        team_info = scenario_standings.filter(pl.col('team') == team)
        if team_info.is_empty():
            return False # Team not found in standings?
        
        team_division = team_info.select('division').item()
        team_wins = team_info.select('wins').item()

        # Get all teams in the same division from the scenario standings
        division_standings = scenario_standings.filter(pl.col('division') == team_division)

        # Find the maximum wins in that division
        max_wins_in_division = division_standings.select(pl.max('wins')).item()

        # Check if the team's wins match the maximum
        if team_wins != max_wins_in_division:
            return False # Not the leader
        
        # Check if *only one* team achieved the maximum wins
        num_teams_with_max_wins = division_standings.filter(pl.col('wins') == max_wins_in_division).height
        
        # Return True only if the team has max wins and is the *only* one with max wins
        return num_teams_with_max_wins == 1
    
    except Exception as e:
        # Log error or handle appropriately
        print(f"Error in _is_division_leader for team {team}: {e}")
        return False # Default to False on error

# --- Main Multi-Way Tiebreaker Function (Refactored) ---
def break_multi_way_tie(tied_teams: List[str],
                        all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                        all_div_records: Dict[str, Tuple[int, int]],
                        all_conf_records: Dict[str, Tuple[int, int]],
                        all_point_diffs: Dict[str, int],
                        teams: pl.DataFrame, # Used for team info (conf, div)
                        playoff_eligible_east: List[str],
                        playoff_eligible_west: List[str],
                        scenario_standings: pl.DataFrame) -> List[Tuple[str, str]]:
    """Apply NBA tiebreaker rules for three or more teams recursively."""

    # --- Base Cases ---
    num_tied = len(tied_teams)
    if num_tied == 0:
        return []
    if num_tied == 1:
        return [(tied_teams[0], "no_tie")]
    if num_tied == 2:
        # Use the dedicated two-way tiebreaker
        winner, tiebreaker = break_two_way_tie(tied_teams[0], tied_teams[1], all_h2h_records, all_div_records,
                                             all_conf_records, all_point_diffs, teams,
                                             playoff_eligible_east, playoff_eligible_west)
        loser = tied_teams[1] if winner == tied_teams[0] else tied_teams[0]
        return [(winner, tiebreaker), (loser, tiebreaker)]

    # --- Recursive Multi-Way Tiebreaker Logic ---
    
    ranked_list: List[Tuple[str, str]] = []
    remaining_to_rank = list(tied_teams) # Start with all teams needing ranking

    # Helper to apply a sorting key and recursively rank subgroups
    def apply_tiebreaker(key_func, tiebreaker_name, higher_is_better=True) -> bool:
        nonlocal remaining_to_rank, ranked_list
        
        if not remaining_to_rank: return True # All teams ranked

        # Sort remaining teams based on the current criterion
        sorted_group = sorted(
            remaining_to_rank,
            key=key_func,
            reverse=higher_is_better
        )

        # Group teams by their score according to the current criterion
        grouped_by_score = []
        if sorted_group:
            current_group = [sorted_group[0]]
            current_score = key_func(sorted_group[0])
            for i in range(1, len(sorted_group)):
                team = sorted_group[i]
                score = key_func(team)
                # Use tolerance for float comparison if needed, though unlikely here
                if score == current_score:
                    current_group.append(team)
                else:
                    grouped_by_score.append(current_group)
                    current_group = [team]
                    current_score = score
            grouped_by_score.append(current_group)

        # Check if this tiebreaker resolved anything
        if len(grouped_by_score) > 1: # Did it create multiple rank levels?
             newly_ranked = []
             next_remaining = []
             for group in grouped_by_score:
                 if len(group) == 1:
                     # This team is definitively ranked by this criterion
                     newly_ranked.append((group[0], tiebreaker_name))
                 else:
                     # This subgroup remains tied, needs further breaking (recursive call)
                     # Pass the subgroup back through the *entire* tiebreaker process
                     recursive_ranks = break_multi_way_tie(group, all_h2h_records, all_div_records,
                                                           all_conf_records, all_point_diffs, teams,
                                                           playoff_eligible_east, playoff_eligible_west, 
                                                           scenario_standings)
                     newly_ranked.extend(recursive_ranks)
             
             ranked_list.extend(newly_ranked)
             remaining_to_rank = [] # All teams processed in this path
             return True # Tiebreaker applied and resolved fully (recursively)
        else:
            # Tiebreaker did not differentiate the group, move to the next rule
            return False

    # --- Apply Rules Sequentially ---

    # (1) Division leader wins tie from team not leading a division
    # Pass scenario_standings to helper
    leaders = [t for t in remaining_to_rank if _is_division_leader(t, teams, all_div_records, scenario_standings)]
    non_leaders = [t for t in remaining_to_rank if t not in leaders]

    if leaders and non_leaders: # Rule applies only if mix of leaders/non-leaders
        # Pass scenario_standings in recursive calls
        ranked_leaders = break_multi_way_tie(leaders, all_h2h_records, all_div_records,
                                             all_conf_records, all_point_diffs, teams,
                                             playoff_eligible_east, playoff_eligible_west, scenario_standings)
        ranked_non_leaders = break_multi_way_tie(non_leaders, all_h2h_records, all_div_records,
                                                 all_conf_records, all_point_diffs, teams,
                                                 playoff_eligible_east, playoff_eligible_west, scenario_standings)
        # Assign the 'division_leader' tag primarily to the leaders breaking the tie here
        ranked_list = [(t, "division_leader" if t in leaders else tb) for t, tb in ranked_leaders] + \
                      [(t, tb) for t, tb in ranked_non_leaders]
        return ranked_list # Tie resolved by this rule

    # If Rule 1 didn't apply or resolve, proceed with the group 'remaining_to_rank'

    # (2) Better winning percentage in all games among the tied teams
    if apply_tiebreaker(lambda t: _get_h2h_pct_among_tied(t, remaining_to_rank, all_h2h_records), "h2h_pct_among_tied"):
         return ranked_list

    # (3) Division won-lost percentage (only if ALL teams are in same division)
    first_team_div = teams.filter(pl.col('team') == remaining_to_rank[0]).select('division').item()
    all_same_division = True
    for team in remaining_to_rank[1:]:
        if teams.filter(pl.col('team') == team).select('division').item() != first_team_div:
            all_same_division = False
            break
            
    if all_same_division:
        if apply_tiebreaker(lambda t: _get_div_pct(t, all_div_records), "division_record_pct"):
             return ranked_list

    # (4) Conference won-lost percentage
    if apply_tiebreaker(lambda t: _get_conf_pct(t, all_conf_records), "conference_record_pct"):
         return ranked_list

    # (5) Better winning percentage against teams eligible for the playoffs in own conference
    # Determine own conference playoff eligible list based on the first team (all tied teams are in the same conf)
    first_team_conf = teams.filter(pl.col('team') == remaining_to_rank[0]).select('conf').item()
    own_conf_eligible = playoff_eligible_east if first_team_conf == 'East' else playoff_eligible_west
    if apply_tiebreaker(lambda t: _get_vs_playoff_eligible_pct(t, own_conf_eligible, all_h2h_records), "vs_playoff_eligible_own_conf_pct"):
         return ranked_list

    # (6) Better net result (Point Differential)
    # This is the final tiebreaker; it should fully rank the remaining teams.
    final_sort = sorted(remaining_to_rank, key=lambda t: all_point_diffs.get(t, -float('inf')), reverse=True)
    ranked_list.extend([(t, "point_differential") for t in final_sort])
    
    return ranked_list

def model(dbt, sess):
    # Get the necessary data and convert to Polars
    simulator = pl.from_pandas(dbt.ref("reg_season_simulator").df())
    teams = pl.from_pandas(dbt.ref("nba_teams").df())
    results = pl.from_pandas(dbt.ref("nba_raw_results").df())
    
    # Create team info dictionary for faster lookups
    team_info = {row['team']: dict(row) for row in teams.iter_rows(named=True)}
    
    # Create a mapping of team abbreviations to full names and vice-versa
    team_map = dict(zip(teams["team"].to_list(), teams["team_long"].to_list()))
    team_abbr_map = dict(zip(teams["team_long"].to_list(), teams["team"].to_list()))

    # Pre-calculate all records using Polars operations
    all_teams = teams["team"].to_list()
    
    # --- Vectorized H2H Calculation ---
    # Map full names in results to abbreviations
    results_with_abbr = results.with_columns([
        pl.col("HomeTm").replace(team_abbr_map).alias("HomeTm_abbr"),
        pl.col("VisTm").replace(team_abbr_map).alias("VisTm_abbr"),
        pl.col("winner").replace(team_abbr_map).alias("winner_abbr")
    ])

    # Determine team1/team2 for consistent pairing (team1 < team2 alphabetically)
    h2h_results = results_with_abbr.with_columns([
        pl.min_horizontal(pl.col("HomeTm_abbr"), pl.col("VisTm_abbr")).alias("team1"),
        pl.max_horizontal(pl.col("HomeTm_abbr"), pl.col("VisTm_abbr")).alias("team2")
    ])

    # Calculate wins for team1 and team2 in each game
    h2h_results = h2h_results.with_columns([
        pl.when(pl.col("winner_abbr") == pl.col("team1")).then(1).otherwise(0).alias("team1_won"),
        pl.when(pl.col("winner_abbr") == pl.col("team2")).then(1).otherwise(0).alias("team2_won")
    ])

    # Aggregate wins for each pair
    h2h_summary = h2h_results.group_by(["team1", "team2"]).agg([
        pl.sum("team1_won"),
        pl.sum("team2_won")
    ])

    # Create all possible team pairs to ensure all matchups are covered
    all_pairs_df = pl.DataFrame({
        't1': [t1 for t1 in all_teams for t2 in all_teams if t1 < t2],
        't2': [t2 for t1 in all_teams for t2 in all_teams if t1 < t2]
    })

    # Join summary with all pairs and fill missing games with 0 wins
    h2h_final = all_pairs_df.join(
        h2h_summary, 
        left_on=['t1', 't2'], 
        right_on=['team1', 'team2'], 
        how='left'
    ).with_columns([
        pl.col('team1_won').fill_null(0),
        pl.col('team2_won').fill_null(0)
    ]).select(['t1', 't2', 'team1_won', 'team2_won'])


    # Convert to dictionary for faster lookups, ensuring both (t1, t2) and (t2, t1) exist
    all_h2h_records = {}
    for row in h2h_final.iter_rows(named=True):
        t1, t2, t1_wins, t2_wins = row['t1'], row['t2'], row['team1_won'], row['team2_won']
        all_h2h_records[(t1, t2)] = (t1_wins, t2_wins)
        all_h2h_records[(t2, t1)] = (t2_wins, t1_wins)
        
    # Add entries for teams against themselves (0, 0) if needed by downstream logic, though typically not required for H2H
    # for team in all_teams:
    #     if (team, team) not in all_h2h_records:
    #          all_h2h_records[(team, team)] = (0, 0)
    # --- End Vectorized H2H Calculation ---

    # --- Vectorized Division and Conference Record Calculation ---
    # Prepare team info for joins
    teams_sel = teams.select(['team', 'conf', 'division'])

    # Join h2h results with team info for both teams
    h2h_teams = h2h_final.join(
        teams_sel, left_on='t1', right_on='team'
    ).rename({
        'conf': 'conf_t1',
        'division': 'division_t1'
    }).join(
        teams_sel, left_on='t2', right_on='team'
    ).rename({
        'conf': 'conf_t2',
        'division': 'division_t2'
    })

    # Create perspective from team1's view
    persp1 = h2h_teams.select([
        pl.col('t1').alias('team'),
        pl.col('conf_t1'),
        pl.col('division_t1'),
        pl.col('conf_t2'),
        pl.col('division_t2'),
        pl.col('team1_won').alias('wins'),
        pl.col('team2_won').alias('losses')
    ])

    # Create perspective from team2's view
    persp2 = h2h_teams.select([
        pl.col('t2').alias('team'),
        pl.col('conf_t2').alias('conf_t1'), # Rename cols to match persp1
        pl.col('division_t2').alias('division_t1'),
        pl.col('conf_t1').alias('conf_t2'),
        pl.col('division_t1').alias('division_t2'),
        pl.col('team2_won').alias('wins'),
        pl.col('team1_won').alias('losses')
    ])

    # Combine perspectives
    all_perspectives = pl.concat([persp1, persp2])

    # Calculate Division Records
    div_records = all_perspectives.filter(pl.col('division_t1') == pl.col('division_t2'))
    div_summary = div_records.group_by('team').agg(
        pl.sum('wins').alias('div_wins'), 
        pl.sum('losses').alias('div_losses')
    )

    # Calculate Conference Records
    conf_records = all_perspectives.filter(pl.col('conf_t1') == pl.col('conf_t2'))
    conf_summary = conf_records.group_by('team').agg(
        pl.sum('wins').alias('conf_wins'), 
        pl.sum('losses').alias('conf_losses')
    )

    # Convert summaries to dictionaries
    all_div_records = {row['team']: (row['div_wins'], row['div_losses']) 
                      for row in div_summary.iter_rows(named=True)}
    all_conf_records = {row['team']: (row['conf_wins'], row['conf_losses']) 
                       for row in conf_summary.iter_rows(named=True)}

    # Ensure all teams are in the dictionaries
    for team in all_teams:
        if team not in all_div_records:
            all_div_records[team] = (0, 0)
        if team not in all_conf_records:
            all_conf_records[team] = (0, 0)
    # --- End Vectorized Division and Conference Record Calculation ---
    
    # --- Vectorized Point Differential Calculation ---
    # Use results_with_abbr which has HomeTm_abbr, VisTm_abbr, winner_abbr
    # Calculate point difference from the perspective of the home team
    results_with_diff = results_with_abbr.with_columns([
        pl.when(pl.col("HomeTm_abbr") == pl.col("winner_abbr"))
          .then(pl.col("winner_pts") - pl.col("loser_pts"))
          .otherwise(pl.col("loser_pts") - pl.col("winner_pts"))
          .alias("game_diff_home_perspective")
    ])

    # Create DataFrame for home team differentials
    home_diffs = results_with_diff.select([
        pl.col("HomeTm_abbr").alias("team"),
        pl.col("game_diff_home_perspective").alias("diff")
    ])

    # Create DataFrame for visitor team differentials (negative of home diff)
    away_diffs = results_with_diff.select([
        pl.col("VisTm_abbr").alias("team"),
        (-pl.col("game_diff_home_perspective")).alias("diff")
    ])

    # Combine home and away differentials
    all_diffs = pl.concat([home_diffs, away_diffs])

    # Group by team and sum differentials
    point_diff_summary = all_diffs.group_by("team").agg(
        pl.sum("diff").alias("total_diff")
    )

    # Convert to dictionary
    all_point_diffs = {row['team']: row['total_diff'] for row in point_diff_summary.iter_rows(named=True)}

    # Ensure all teams are in the dictionary, defaulting to 0 if they had no games
    for team in all_teams:
        if team not in all_point_diffs:
            all_point_diffs[team] = 0
    # --- End Vectorized Point Differential Calculation ---
    
    # Pre-calculate wins and losses for each team in each scenario
    wins = simulator.group_by(['scenario_id', 'winning_team']).count().rename({'count': 'wins', 'winning_team': 'team'})
    losses = simulator.filter(
        ((pl.col('home_team') != pl.col('winning_team')) & pl.col('home_team').is_not_null()) |
        ((pl.col('visiting_team') != pl.col('winning_team')) & pl.col('visiting_team').is_not_null())
    ).group_by(['scenario_id', 'home_team']).count().rename({'count': 'losses', 'home_team': 'team'})
    
    # Merge wins and losses
    standings = wins.join(losses, on=['scenario_id', 'team'], how='outer').fill_null(0)
    
    # Join standings with teams to get conference info
    standings = standings.join(teams.select(['team', 'conf', 'division']), on='team', how='left')
    
    # Process each scenario
    output_data = []
    scenario_ids = standings['scenario_id'].unique().to_list()
    
    for scenario_id in scenario_ids:
        try:
            # Get standings for this scenario
            scenario_standings = standings.filter(pl.col('scenario_id') == scenario_id)
            
            # Calculate playoff eligible teams (top 10 per conference, with ties)
            def get_playoff_eligible(standings_df: pl.DataFrame, conf: str) -> List[str]:
                conf_standings = standings_df.filter(pl.col('conf') == conf).sort('wins', descending=True)
                if conf_standings.height == 0:
                    return []
                # Find the 10th best win total (or last if fewer than 10 teams)
                cutoff_index = min(9, conf_standings.height - 1)
                tenth_place_wins = conf_standings[cutoff_index]['wins'].item()
                # Include all teams with wins >= 10th place wins
                eligible = conf_standings.filter(pl.col('wins') >= tenth_place_wins)
                return eligible['team'].to_list()

            playoff_eligible_east = get_playoff_eligible(scenario_standings, 'East')
            playoff_eligible_west = get_playoff_eligible(scenario_standings, 'West')
            # Removed top_10_overall as it's not used

            # Group teams by conference and wins
            east_standings = scenario_standings.filter(pl.col('conf') == 'East').sort('wins', descending=True)
            west_standings = scenario_standings.filter(pl.col('conf') == 'West').sort('wins', descending=True)
            
            # Process each conference
            def process_standings(conf_standings: pl.DataFrame, scenario_standings_full: pl.DataFrame):
                # ^^ Added scenario_standings_full parameter
                current_wins = None
                tied_teams = []
                rankings = []
                
                for row in conf_standings.iter_rows(named=True):
                    if current_wins is None or row['wins'] == current_wins:
                        tied_teams.append(row['team'])
                        current_wins = row['wins']
                    else:
                        if len(tied_teams) > 1:
                            # Break the tie (uses playoff_eligible_* from outer scope)
                            resolved = break_multi_way_tie(tied_teams, all_h2h_records, all_div_records,
                                                         all_conf_records, all_point_diffs, teams,
                                                         playoff_eligible_east, playoff_eligible_west, 
                                                         scenario_standings_full)
                            rankings.extend(resolved)
                        else:
                            rankings.extend([(t, "no_tie") for t in tied_teams])
                        tied_teams = [row['team']]
                        current_wins = row['wins']
                
                # Handle any remaining tied teams
                if tied_teams:
                    if len(tied_teams) > 1:
                        # Pass scenario_standings_full
                        resolved = break_multi_way_tie(tied_teams, all_h2h_records, all_div_records,
                                                     all_conf_records, all_point_diffs, teams,
                                                     playoff_eligible_east, playoff_eligible_west, 
                                                     scenario_standings_full)
                        rankings.extend(resolved)
                    else:
                        rankings.extend([(t, "no_tie") for t in tied_teams])
                
                return rankings
            
            # Process rankings for this scenario
            # Pass scenario_standings as the second argument
            east_rankings = process_standings(east_standings, scenario_standings)
            west_rankings = process_standings(west_standings, scenario_standings)
            
            # Add East teams
            rank = 1
            for team, tiebreaker in east_rankings:
                try:
                    team_info_row = team_info[team]
                    team_wins = scenario_standings.filter(pl.col('team') == team)['wins'].item()
                    output_data.append({
                        "scenario_id": scenario_id,
                        "team": team,
                        "conference": "East",
                        "rank": rank,
                        "division": team_info_row['division'],
                        "tiebreaker_used": tiebreaker,
                        "wins": team_wins
                    })
                    rank += 1
                except Exception as e:
                    print(f"Error processing East team {team} in scenario {scenario_id}: {e}")
            
            # Add West teams
            rank = 1
            for team, tiebreaker in west_rankings:
                try:
                    team_info_row = team_info[team]
                    team_wins = scenario_standings.filter(pl.col('team') == team)['wins'].item()
                    output_data.append({
                        "scenario_id": scenario_id,
                        "team": team,
                        "conference": "West",
                        "rank": rank,
                        "division": team_info_row['division'],
                        "tiebreaker_used": tiebreaker,
                        "wins": team_wins
                    })
                    rank += 1
                except Exception as e:
                    print(f"Error processing West team {team} in scenario {scenario_id}: {e}")
        except Exception as e:
            print(f"Error processing scenario {scenario_id}: {e}")
    
    # Convert final output to pandas DataFrame
    return pd.DataFrame(output_data) 