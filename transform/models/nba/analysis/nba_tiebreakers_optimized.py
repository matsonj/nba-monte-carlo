import pandas as pd
import polars as pl
import numpy as np
from typing import List, Dict, Tuple, Optional

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

def break_two_way_tie(team1: str, team2: str, all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                     all_div_records: Dict[str, Tuple[int, int]], all_conf_records: Dict[str, Tuple[int, int]],
                     all_point_diffs: Dict[str, int], teams: pl.DataFrame,
                     top_10_east: List[str], top_10_west: List[str], top_10_overall: List[str]) -> Tuple[str, str]:
    """Apply tiebreaker rules for two teams. Returns (winner, tiebreaker_used)."""
    team1_info = teams.filter(pl.col('team') == team1).row(0)
    team2_info = teams.filter(pl.col('team') == team2).row(0)
    
    # 1. Head-to-head record
    team1_h2h_wins, team2_h2h_wins = all_h2h_records[(team1, team2)]
    if team1_h2h_wins > team2_h2h_wins:
        return team1, "head_to_head"
    elif team2_h2h_wins > team1_h2h_wins:
        return team2, "head_to_head"
    
    # 2. Division winner (if in same division)
    if team1_info[2] == team2_info[2]:  # division
        team1_div_wins, _ = all_div_records[team1]
        team2_div_wins, _ = all_div_records[team2]
        if team1_div_wins > team2_div_wins:
            return team1, "division_record"
        elif team2_div_wins > team1_div_wins:
            return team2, "division_record"
    
    # 3. Conference record
    team1_conf_wins, _ = all_conf_records[team1]
    team2_conf_wins, _ = all_conf_records[team2]
    if team1_conf_wins > team2_conf_wins:
        return team1, "conference_record"
    elif team2_conf_wins > team1_conf_wins:
        return team2, "conference_record"
    
    # 4. Record against top-10 in conference
    top_10_conf = top_10_east if team1_info[1] == 'East' else top_10_west
    team1_top10_wins = sum(all_h2h_records[(team1, t)][0] for t in top_10_conf if t != team1)
    team2_top10_wins = sum(all_h2h_records[(team2, t)][0] for t in top_10_conf if t != team2)
    if team1_top10_wins > team2_top10_wins:
        return team1, "top_10_conference"
    elif team2_top10_wins > team1_top10_wins:
        return team2, "top_10_conference"
    
    # 5. Record against top-10 overall
    team1_top10_wins = sum(all_h2h_records[(team1, t)][0] for t in top_10_overall if t != team1)
    team2_top10_wins = sum(all_h2h_records[(team2, t)][0] for t in top_10_overall if t != team2)
    if team1_top10_wins > team2_top10_wins:
        return team1, "top_10_overall"
    elif team2_top10_wins > team1_top10_wins:
        return team2, "top_10_overall"
    
    # 6. Point differential
    team1_diff = all_point_diffs[team1]
    team2_diff = all_point_diffs[team2]
    if team1_diff > team2_diff:
        return team1, "point_differential"
    else:
        return team2, "point_differential"

# --- Helper functions for multi-way tiebreakers ---

def _get_division_winners(tied_teams: List[str], all_div_records: Dict[str, Tuple[int, int]], teams: pl.DataFrame) -> Tuple[List[str], List[str]]:
    """Identifies division leaders among tied teams based on simplified original logic."""
    # Simplified logic from original code: Check if a team has > 0 division wins.
    # A more complex/accurate check would be needed for official NBA rules (best record within division).
    division_winners = []
    remaining_teams = []
    for team in tied_teams:
        # Use .get to handle potential missing keys gracefully
        div_wins, _ = all_div_records.get(team, (0, 0))
        # Original logic used '> 0', assuming pre-calculated div wins reflect leadership.
        # Let's stick to that for direct refactoring, but acknowledge it might be inaccurate.
        # A better check might involve comparing records of teams *within the same division*.
        team_info = teams.filter(pl.col('team') == team)
        if not team_info.is_empty():
            # This check requires knowing if the team *won* its division, which all_div_records doesn't directly state.
            # The original check `if div_wins > 0:` is ambiguous. Let's refine slightly to check if they are *marked* as a division winner.
            # Assuming 'division_winner' status is somehow derivable or stored elsewhere (e.g., in teams table, though not used before).
            # For now, let's replicate the *intent* of separating based on division record superiority within the tied group.
            # A placeholder check - replace with actual division winner logic if available
            # We'll stick closer to the *original* implementation structure which seemed to just sort winners if multiple existed.
            # Let's identify potential leaders based on having the best div record *within their division subset of the tie*
            pass # Actual division winner logic is complex, deferring for now.

    # Sticking to the original logic's *structure* which separated winners/remainders then sorted.
    # Let's identify teams that *could* be division winners based on having *any* div wins.
    potential_winners = [t for t in tied_teams if all_div_records.get(t, (0,0))[0] > 0]
    remaining_teams = [t for t in tied_teams if t not in potential_winners]

    # If multiple potential winners, sort them by div wins. The original code did this.
    if len(potential_winners) > 1:
       potential_winners = sorted(potential_winners, key=lambda x: all_div_records.get(x, (0,0))[0], reverse=True)

    # This function will return the potentially sorted list of winners and the rest.
    # The calling function needs to handle the cases (0, 1, or multiple winners)
    return potential_winners, remaining_teams


def _sort_by_multi_h2h(tied_teams: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]]) -> Tuple[List[str], Dict[str, int]]:
    """Sorts tied teams by their head-to-head record wins against each other."""
    h2h_records = {}
    for team in tied_teams:
        wins = sum(all_h2h_records.get((team, opponent), (0, 0))[0] for opponent in tied_teams if opponent != team)
        h2h_records[team] = wins
    sorted_teams = sorted(tied_teams, key=lambda x: h2h_records.get(x, 0), reverse=True)
    return sorted_teams, h2h_records

def _sort_by_conf_record(tied_teams: List[str], all_conf_records: Dict[str, Tuple[int, int]]) -> Tuple[List[str], Dict[str, int]]:
    """Sorts tied teams by their conference record wins."""
    conf_wins = {team: all_conf_records.get(team, (0, 0))[0] for team in tied_teams}
    sorted_teams = sorted(tied_teams, key=lambda x: conf_wins.get(x, 0), reverse=True)
    return sorted_teams, conf_wins

def _sort_by_point_diff(tied_teams: List[str], all_point_diffs: Dict[str, int]) -> List[str]:
    """Sorts tied teams by their overall point differential."""
    sorted_teams = sorted(tied_teams, key=lambda x: all_point_diffs.get(x, -float('inf')), reverse=True)
    return sorted_teams

# --- End Helper functions ---

def break_multi_way_tie(tied_teams: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                       all_div_records: Dict[str, Tuple[int, int]], all_conf_records: Dict[str, Tuple[int, int]],
                       all_point_diffs: Dict[str, int], teams: pl.DataFrame,
                       top_10_east: List[str], top_10_west: List[str], top_10_overall: List[str]) -> List[Tuple[str, str]]:
    """Apply tiebreaker rules for three or more teams using helper functions."""

    # Base case: Two teams use the dedicated two-way tiebreaker
    if len(tied_teams) <= 1:
        return [(team, "no_tie") for team in tied_teams] # Handle empty or single team list
    
    if len(tied_teams) == 2:
        winner, tiebreaker = break_two_way_tie(tied_teams[0], tied_teams[1], all_h2h_records, all_div_records,
                                             all_conf_records, all_point_diffs, teams,
                                             top_10_east, top_10_west, top_10_overall)
        loser = tied_teams[1] if winner == tied_teams[0] else tied_teams[0]
        return [(winner, tiebreaker), (loser, tiebreaker)]

    # --- Multi-way tiebreaker logic ---
    # Make a copy to work with
    current_tied_teams = list(tied_teams)

    # 1. Division winner rule (Simplified based on original implementation)
    # Get potential division winners (teams with >0 div wins) and others
    # The helper sorts multiple winners by div wins.
    division_winners, remaining_teams = _get_division_winners(current_tied_teams, all_div_records, teams)

    if division_winners:
        # If only one winner, they are ranked first. Break tie among remaining.
        if len(division_winners) == 1:
            winner = division_winners[0]
            remaining_ranked = break_multi_way_tie(remaining_teams, all_h2h_records, all_div_records,
                                                 all_conf_records, all_point_diffs, teams,
                                                 top_10_east, top_10_west, top_10_overall)
            return [(winner, "division_winner")] + remaining_ranked
        # If multiple winners, rank them first (already sorted by helper), then rank remaining.
        else:
            # Keep the 'division_winner' tiebreaker tag for all winners as per original code.
            winners_ranked = [(team, "division_winner") for team in division_winners]
            remaining_ranked = break_multi_way_tie(remaining_teams, all_h2h_records, all_div_records,
                                                   all_conf_records, all_point_diffs, teams,
                                                   top_10_east, top_10_west, top_10_overall)
            return winners_ranked + remaining_ranked

    # If no division winners involved, proceed with the entire group.
    # 2. Head-to-head record among all tied teams
    sorted_by_h2h, h2h_wins = _sort_by_multi_h2h(current_tied_teams, all_h2h_records)
    # Check if H2H resolves the tie (is the top team strictly better than the second?)
    if h2h_wins.get(sorted_by_h2h[0], 0) > h2h_wins.get(sorted_by_h2h[1], 0):
        # Original code returned the full sorted list if H2H broke *any* part of the tie.
        return [(team, "head_to_head") for team in sorted_by_h2h]

    # 3. Conference record among tied teams
    # Only apply if H2H resulted in a tie at the top.
    sorted_by_conf, conf_wins = _sort_by_conf_record(current_tied_teams, all_conf_records)
    if conf_wins.get(sorted_by_conf[0], 0) > conf_wins.get(sorted_by_conf[1], 0):
        return [(team, "conference_record") for team in sorted_by_conf]

    # 4. Point differential (overall)
    # Applied if conference record also resulted in a tie at the top.
    sorted_by_diff = _sort_by_point_diff(current_tied_teams, all_point_diffs)
    return [(team, "point_differential") for team in sorted_by_diff]

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
            
            # Calculate top 10 teams (moved back to scenario level)
            top_10_east = scenario_standings.filter(pl.col('conf') == 'East').sort('wins', descending=True).head(10)['team'].to_list()
            top_10_west = scenario_standings.filter(pl.col('conf') == 'West').sort('wins', descending=True).head(10)['team'].to_list()
            top_10_overall = scenario_standings.sort('wins', descending=True).head(10)['team'].to_list()
            
            # Group teams by conference and wins
            east_standings = scenario_standings.filter(pl.col('conf') == 'East').sort('wins', descending=True)
            west_standings = scenario_standings.filter(pl.col('conf') == 'West').sort('wins', descending=True)
            
            # Process each conference
            def process_standings(conf_standings: pl.DataFrame):
                # ^^ Removed scenario_standings_full parameter
                current_wins = None
                tied_teams = []
                rankings = []
                
                for row in conf_standings.iter_rows(named=True):
                    if current_wins is None or row['wins'] == current_wins:
                        tied_teams.append(row['team'])
                        current_wins = row['wins']
                    else:
                        if len(tied_teams) > 1:
                            # Break the tie (uses top_10_* from outer scope)
                            resolved = break_multi_way_tie(tied_teams, all_h2h_records, all_div_records,
                                                         all_conf_records, all_point_diffs, teams,
                                                         top_10_east, top_10_west, top_10_overall)
                            rankings.extend(resolved)
                        else:
                            rankings.extend([(t, "no_tie") for t in tied_teams])
                        tied_teams = [row['team']]
                        current_wins = row['wins']
                
                # Handle any remaining tied teams
                if tied_teams:
                    if len(tied_teams) > 1:
                        resolved = break_multi_way_tie(tied_teams, all_h2h_records, all_div_records,
                                                     all_conf_records, all_point_diffs, teams,
                                                     top_10_east, top_10_west, top_10_overall)
                        rankings.extend(resolved)
                    else:
                        rankings.extend([(t, "no_tie") for t in tied_teams])
                
                return rankings
            
            # Process rankings for this scenario
            # Remove second argument from calls
            east_rankings = process_standings(east_standings)
            west_rankings = process_standings(west_standings)
            
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