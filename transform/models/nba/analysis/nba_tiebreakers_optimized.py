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

def break_multi_way_tie(tied_teams: List[str], all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                       all_div_records: Dict[str, Tuple[int, int]], all_conf_records: Dict[str, Tuple[int, int]],
                       all_point_diffs: Dict[str, int], teams: pl.DataFrame,
                       top_10_east: List[str], top_10_west: List[str], top_10_overall: List[str]) -> List[Tuple[str, str]]:
    """Apply tiebreaker rules for three or more teams. Returns list of (team, tiebreaker_used)."""
    if len(tied_teams) == 2:
        winner, tiebreaker = break_two_way_tie(tied_teams[0], tied_teams[1], all_h2h_records, all_div_records,
                                             all_conf_records, all_point_diffs, teams,
                                             top_10_east, top_10_west, top_10_overall)
        loser = tied_teams[1] if winner == tied_teams[0] else tied_teams[0]
        return [(winner, tiebreaker), (loser, tiebreaker)]
    
    # Get team info for all tied teams
    tied_teams_info = teams.filter(pl.col('team').is_in(tied_teams))
    
    # 1. Division winners get priority
    division_winners = []
    remaining_teams = []
    for team in tied_teams:
        team_info = teams.filter(pl.col('team') == team).row(0)
        div_wins, _ = all_div_records[team]
        if div_wins > 0:  # If team has best division record
            division_winners.append(team)
        else:
            remaining_teams.append(team)
    
    if division_winners:
        if len(division_winners) == 1:
            return [(division_winners[0], "division_winner")] + break_multi_way_tie(remaining_teams, all_h2h_records,
                                                                                 all_div_records, all_conf_records,
                                                                                 all_point_diffs, teams,
                                                                                 top_10_east, top_10_west, top_10_overall)
        else:
            return break_multi_way_tie(division_winners, all_h2h_records, all_div_records,
                                     all_conf_records, all_point_diffs, teams,
                                     top_10_east, top_10_west, top_10_overall) + [(t, "division_winner") for t in remaining_teams]
    
    # 2. Record against other tied teams
    h2h_records = {}
    for team in tied_teams:
        wins = sum(all_h2h_records[(team, opponent)][0] for opponent in tied_teams if opponent != team)
        h2h_records[team] = wins
    
    # Sort by head-to-head record
    sorted_teams = sorted(tied_teams, key=lambda x: h2h_records[x], reverse=True)
    
    # If there's a clear winner, return that team first and break remaining ties
    if h2h_records[sorted_teams[0]] > h2h_records[sorted_teams[1]]:
        return [(sorted_teams[0], "head_to_head")] + break_multi_way_tie(sorted_teams[1:], all_h2h_records,
                                                                       all_div_records, all_conf_records,
                                                                       all_point_diffs, teams,
                                                                       top_10_east, top_10_west, top_10_overall)
    
    # If still tied, continue with other criteria
    # For now, return the current order with "multiple_tie" as the tiebreaker
    return [(t, "multiple_tie") for t in sorted_teams]

def model(dbt, sess):
    # Get the necessary data and convert to Polars
    simulator = pl.from_pandas(dbt.ref("reg_season_simulator").df())
    teams = pl.from_pandas(dbt.ref("nba_teams").df())
    results = pl.from_pandas(dbt.ref("nba_raw_results").df())
    
    # Create a mapping of team abbreviations to full names
    team_map = dict(zip(teams["team"].to_list(), teams["team_long"].to_list()))
    
    # Pre-calculate all records
    all_teams = teams["team"].to_list()
    all_h2h_records = {}
    all_div_records = {}
    all_conf_records = {}
    all_point_diffs = {}
    
    # Pre-calculate head-to-head records
    for team1 in all_teams:
        team1_full = team_map[team1]
        for team2 in all_teams:
            if team1 != team2:
                team2_full = team_map[team2]
                h2h_games = results.filter(
                    ((pl.col('VisTm') == team1_full) & (pl.col('HomeTm') == team2_full)) |
                    ((pl.col('VisTm') == team2_full) & (pl.col('HomeTm') == team1_full))
                )
                team1_wins = h2h_games.filter(pl.col('winner') == team1_full).height
                team2_wins = h2h_games.filter(pl.col('winner') == team2_full).height
                all_h2h_records[(team1, team2)] = (team1_wins, team2_wins)
    
    # Pre-calculate division records
    for team in all_teams:
        team_full = team_map[team]
        team_info = teams.filter(pl.col('team') == team).row(0)
        division = team_info[2]
        conference = team_info[1]
        
        # Division record
        division_teams = teams.filter(pl.col('division') == division)['team'].to_list()
        if team in division_teams:
            division_teams.remove(team)
        division_teams_full = [team_map[t] for t in division_teams]
        div_games = results.filter(
            ((pl.col('VisTm') == team_full) & (pl.col('HomeTm').is_in(division_teams_full))) |
            ((pl.col('HomeTm') == team_full) & (pl.col('VisTm').is_in(division_teams_full)))
        )
        div_wins = div_games.filter(pl.col('winner') == team_full).height
        div_losses = div_games.filter(pl.col('winner') != team_full).height
        all_div_records[team] = (div_wins, div_losses)
        
        # Conference record
        conf_teams = teams.filter(pl.col('conf') == conference)['team'].to_list()
        if team in conf_teams:
            conf_teams.remove(team)
        conf_teams_full = [team_map[t] for t in conf_teams]
        conf_games = results.filter(
            ((pl.col('VisTm') == team_full) & (pl.col('HomeTm').is_in(conf_teams_full))) |
            ((pl.col('HomeTm') == team_full) & (pl.col('VisTm').is_in(conf_teams_full)))
        )
        conf_wins = conf_games.filter(pl.col('winner') == team_full).height
        conf_losses = conf_games.filter(pl.col('winner') != team_full).height
        all_conf_records[team] = (conf_wins, conf_losses)
        
        # Point differential
        home_games = results.filter(pl.col('HomeTm') == team_full)
        home_diff = home_games.with_columns(
            diff=pl.when(pl.col('winner') == team_full)
            .then(pl.col('winner_pts') - pl.col('loser_pts'))
            .otherwise(pl.col('loser_pts') - pl.col('winner_pts'))
        )['diff'].sum()
        
        away_games = results.filter(pl.col('VisTm') == team_full)
        away_diff = away_games.with_columns(
            diff=pl.when(pl.col('winner') == team_full)
            .then(pl.col('winner_pts') - pl.col('loser_pts'))
            .otherwise(pl.col('loser_pts') - pl.col('winner_pts'))
        )['diff'].sum()
        
        all_point_diffs[team] = home_diff + away_diff
    
    # Pre-calculate wins and losses for each team in each scenario
    # First calculate wins
    wins = simulator.group_by(['scenario_id', 'winning_team']).count().rename({'count': 'wins', 'winning_team': 'team'})
    
    # Then calculate losses (team is the losing team if they are home/visiting team and not the winning team)
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
        # Get standings for this scenario
        scenario_standings = standings.filter(pl.col('scenario_id') == scenario_id)
        
        # Calculate top 10 teams in each conference for this scenario
        top_10_east = scenario_standings.filter(pl.col('conf') == 'East').sort('wins', descending=True).head(10)['team'].to_list()
        top_10_west = scenario_standings.filter(pl.col('conf') == 'West').sort('wins', descending=True).head(10)['team'].to_list()
        top_10_overall = scenario_standings.sort('wins', descending=True).head(10)['team'].to_list()
        
        # Group teams by conference and wins
        east_standings = scenario_standings.filter(pl.col('conf') == 'East').sort('wins', descending=True)
        west_standings = scenario_standings.filter(pl.col('conf') == 'West').sort('wins', descending=True)
        
        # Process each conference
        def process_standings(conf_standings):
            current_wins = None
            tied_teams = []
            rankings = []
            
            for row in conf_standings.iter_rows(named=True):
                if current_wins is None or row['wins'] == current_wins:
                    tied_teams.append(row['team'])
                    current_wins = row['wins']
                else:
                    if len(tied_teams) > 1:
                        # Break the tie
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
        east_rankings = process_standings(east_standings)
        west_rankings = process_standings(west_standings)
        
        # Add East teams
        rank = 1
        for team, tiebreaker in east_rankings:
            team_info = teams.filter(pl.col('team') == team).row(0)
            team_wins = scenario_standings.filter(pl.col('team') == team)['wins'].item()
            output_data.append({
                "scenario_id": scenario_id,
                "team": team,
                "conference": "East",
                "rank": rank,
                "division": team_info[5],  # division
                "tiebreaker_used": tiebreaker,
                "wins": team_wins
            })
            rank += 1
        
        # Add West teams
        rank = 1
        for team, tiebreaker in west_rankings:
            team_info = teams.filter(pl.col('team') == team).row(0)
            team_wins = scenario_standings.filter(pl.col('team') == team)['wins'].item()
            output_data.append({
                "scenario_id": scenario_id,
                "team": team,
                "conference": "West",
                "rank": rank,
                "division": team_info[5],  # division
                "tiebreaker_used": tiebreaker,
                "wins": team_wins
            })
            rank += 1
    
    # Convert final output to pandas DataFrame
    return pd.DataFrame(output_data) 