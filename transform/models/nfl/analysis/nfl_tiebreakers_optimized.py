import pandas as pd
import polars as pl
import numpy as np
from typing import List, Dict, Tuple, Optional

# NFL TIEBREAKER RULES IMPLEMENTATION
# Two Clubs:
# (1) Head-to-head record
# (2) Division record (if both teams in same division)
# (3) Common games record
# (4) Conference record
# (5) Strength of victory
# (6) Strength of schedule
# (7-12) Point-based tiebreakers (skipped - no score data)
#
# Three or More Clubs:
# (1) Head-to-head record among tied teams
# (2) Division record (if all teams in same division)
# (3) Common games record
# (4) Conference record
# (5) Strength of victory
# (6) Strength of schedule
# (7-12) Point-based tiebreakers (skipped - no score data)

def calculate_head_to_head(team1: str, team2: str, results: pl.DataFrame) -> Tuple[int, int]:
    """Calculate head-to-head record between two teams."""
    h2h_games = results.filter(
        ((pl.col('visiting_team') == team1) & (pl.col('home_team') == team2)) |
        ((pl.col('visiting_team') == team2) & (pl.col('home_team') == team1))
    )
    
    team1_wins = h2h_games.filter(pl.col('winning_team') == team1).height
    team2_wins = h2h_games.filter(pl.col('winning_team') == team2).height
    
    return team1_wins, team2_wins

def calculate_division_record(team: str, division: str, results: pl.DataFrame, teams: pl.DataFrame) -> Tuple[int, int]:
    """Calculate a team's record against teams in their division."""
    division_teams = teams.filter(pl.col('division') == division)['team'].to_list()
    if team in division_teams:
        division_teams.remove(team)
    
    div_games = results.filter(
        ((pl.col('visiting_team') == team) & (pl.col('home_team').is_in(division_teams))) |
        ((pl.col('home_team') == team) & (pl.col('visiting_team').is_in(division_teams)))
    )
    
    wins = div_games.filter(pl.col('winning_team') == team).height
    losses = div_games.filter(pl.col('winning_team') != team).height
    
    return wins, losses

def calculate_conference_record(team: str, conference: str, results: pl.DataFrame, teams: pl.DataFrame) -> Tuple[int, int]:
    """Calculate a team's record against teams in their conference."""
    conf_teams = teams.filter(pl.col('conf') == conference)['team'].to_list()
    if team in conf_teams:
        conf_teams.remove(team)
    
    conf_games = results.filter(
        ((pl.col('visiting_team') == team) & (pl.col('home_team').is_in(conf_teams))) |
        ((pl.col('home_team') == team) & (pl.col('visiting_team').is_in(conf_teams)))
    )
    
    wins = conf_games.filter(pl.col('winning_team') == team).height
    losses = conf_games.filter(pl.col('winning_team') != team).height
    
    return wins, losses

def calculate_common_games_record(team: str, tied_teams: List[str], results: pl.DataFrame) -> Tuple[int, int]:
    """Calculate a team's record in games against common opponents."""
    # Find opponents that all tied teams have played
    all_opponents = {}
    
    for t in [team] + tied_teams:
        team_games = results.filter(
            (pl.col('visiting_team') == t) | (pl.col('home_team') == t)
        )
        opponents = set()
        for row in team_games.iter_rows(named=True):
            opp = row['home_team'] if row['visiting_team'] == t else row['visiting_team']
            if opp not in [team] + tied_teams:  # Exclude tied teams themselves
                opponents.add(opp)
        all_opponents[t] = opponents
    
    # Find common opponents (opponents played by ALL tied teams)
    common_opponents = set.intersection(*all_opponents.values()) if all_opponents else set()
    common_opponents = list(common_opponents)
    
    if not common_opponents:
        return 0, 0
    
    # Calculate record against common opponents
    common_games = results.filter(
        ((pl.col('visiting_team') == team) & (pl.col('home_team').is_in(common_opponents))) |
        ((pl.col('home_team') == team) & (pl.col('visiting_team').is_in(common_opponents)))
    )
    
    wins = common_games.filter(pl.col('winning_team') == team).height
    losses = common_games.filter(pl.col('winning_team') != team).height
    
    return wins, losses

def calculate_strength_of_victory(team: str, results: pl.DataFrame, all_team_records: Dict[str, Tuple[int, int]]) -> float:
    """Calculate strength of victory (combined win% of teams this team beat)."""
    team_wins = results.filter(pl.col('winning_team') == team)
    
    if team_wins.height == 0:
        return 0.0
    
    total_beaten_wins = 0
    total_beaten_games = 0
    
    for row in team_wins.iter_rows(named=True):
        beaten_team = row['home_team'] if row['visiting_team'] == team else row['visiting_team']
        beaten_wins, beaten_losses = all_team_records.get(beaten_team, (0, 0))
        total_beaten_wins += beaten_wins
        total_beaten_games += beaten_wins + beaten_losses
    
    return total_beaten_wins / total_beaten_games if total_beaten_games > 0 else 0.0

def calculate_strength_of_schedule(team: str, results: pl.DataFrame, all_team_records: Dict[str, Tuple[int, int]]) -> float:
    """Calculate strength of schedule (combined win% of all opponents)."""
    team_games = results.filter(
        (pl.col('visiting_team') == team) | (pl.col('home_team') == team)
    )
    
    if team_games.height == 0:
        return 0.0
    
    total_opp_wins = 0
    total_opp_games = 0
    
    for row in team_games.iter_rows(named=True):
        opponent = row['home_team'] if row['visiting_team'] == team else row['visiting_team']
        opp_wins, opp_losses = all_team_records.get(opponent, (0, 0))
        total_opp_wins += opp_wins
        total_opp_games += opp_wins + opp_losses
    
    return total_opp_wins / total_opp_games if total_opp_games > 0 else 0.0

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
        if team == opponent:
            continue
        w, l = all_h2h_records.get((team, opponent), (0, 0))
        wins += w
        losses += l
    return wins, losses

def break_two_way_tie(team1: str, team2: str,
                      all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                      all_div_records: Dict[str, Tuple[int, int]],
                      all_conf_records: Dict[str, Tuple[int, int]],
                      all_common_records: Dict,
                      all_sov: Dict[str, float],
                      all_sos: Dict[str, float],
                      teams: pl.DataFrame,
                      results: pl.DataFrame) -> Tuple[str, str]:
    """Apply NFL tiebreaker rules for two teams. Returns (winner, tiebreaker_used)."""
    
    team1_info = teams.filter(pl.col('team') == team1).row(index=0, named=True)
    team2_info = teams.filter(pl.col('team') == team2).row(index=0, named=True)
    if not team1_info or not team2_info:
        return team1, "error_missing_team_info"

    # (1) Head-to-head record
    t1_h2h_wins, t2_h2h_wins = all_h2h_records.get((team1, team2), (0, 0))
    if t1_h2h_wins > t2_h2h_wins:
        return team1, "h2h_wins"
    if t2_h2h_wins > t1_h2h_wins:
        return team2, "h2h_wins"

    # (2) Division record (only if teams are in same division)
    if team1_info['division'] == team2_info['division']:
        t1_div_wins, t1_div_losses = all_div_records.get(team1, (0, 0))
        t2_div_wins, t2_div_losses = all_div_records.get(team2, (0, 0))
        t1_div_pct = _calculate_win_percentage(t1_div_wins, t1_div_losses)
        t2_div_pct = _calculate_win_percentage(t2_div_wins, t2_div_losses)
        if t1_div_pct > t2_div_pct:
            return team1, "division_record_pct"
        if t2_div_pct > t1_div_pct:
            return team2, "division_record_pct"

    # (3) Common games record
    # Calculate common games record between the two teams
    team1_common_wins, team1_common_losses = calculate_common_games_record(team1, [team2], results)
    team2_common_wins, team2_common_losses = calculate_common_games_record(team2, [team1], results)
    
    # Only apply if both teams have common games
    if team1_common_wins + team1_common_losses > 0 and team2_common_wins + team2_common_losses > 0:
        team1_common_pct = _calculate_win_percentage(team1_common_wins, team1_common_losses)
        team2_common_pct = _calculate_win_percentage(team2_common_wins, team2_common_losses)
        if team1_common_pct > team2_common_pct:
            return team1, "common_games_pct"
        if team2_common_pct > team1_common_pct:
            return team2, "common_games_pct"

    # (4) Conference record
    t1_conf_wins, t1_conf_losses = all_conf_records.get(team1, (0, 0))
    t2_conf_wins, t2_conf_losses = all_conf_records.get(team2, (0, 0))
    t1_conf_pct = _calculate_win_percentage(t1_conf_wins, t1_conf_losses)
    t2_conf_pct = _calculate_win_percentage(t2_conf_wins, t2_conf_losses)
    if t1_conf_pct > t2_conf_pct:
        return team1, "conference_record_pct"
    if t2_conf_pct > t1_conf_pct:
        return team2, "conference_record_pct"

    # (5) Strength of victory
    team1_sov = all_sov.get(team1, 0.0)
    team2_sov = all_sov.get(team2, 0.0)
    if team1_sov > team2_sov:
        return team1, "strength_of_victory"
    if team2_sov > team1_sov:
        return team2, "strength_of_victory"

    # (6) Strength of schedule
    team1_sos = all_sos.get(team1, 0.0)
    team2_sos = all_sos.get(team2, 0.0)
    if team1_sos > team2_sos:
        return team1, "strength_of_schedule"
    if team2_sos > team1_sos:
        return team2, "strength_of_schedule"

    # Final fallback (coin toss equivalent)
    return team1, "coin_toss"

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

def _get_common_games_pct(team: str, tied_group: List[str], results: pl.DataFrame) -> float:
    """Gets common games win pct for a team against tied group (calculated on-demand)."""
    wins, losses = calculate_common_games_record(team, tied_group, results)
    return _calculate_win_percentage(wins, losses)

def break_multi_way_tie(tied_teams: List[str],
                        all_h2h_records: Dict[Tuple[str, str], Tuple[int, int]],
                        all_div_records: Dict[str, Tuple[int, int]],
                        all_conf_records: Dict[str, Tuple[int, int]],
                        all_sov: Dict[str, float],
                        all_sos: Dict[str, float],
                        teams: pl.DataFrame,
                        results: pl.DataFrame) -> List[Tuple[str, str]]:
    """Break ties among 3+ teams. Returns list of (team, tiebreaker_used) in order."""
    
    if len(tied_teams) <= 1:
        return [(tied_teams[0], "no_tie")] if tied_teams else []
    
    if len(tied_teams) == 2:
        # For two teams, we don't need the common games logic
        winner, tb = break_two_way_tie(
            tied_teams[0], tied_teams[1],
            all_h2h_records, all_div_records, all_conf_records,
            {}, all_sov, all_sos, teams, results  # Empty dict for common records
        )
        loser = tied_teams[1] if winner == tied_teams[0] else tied_teams[0]
        return [(winner, tb), (loser, tb)]
    
    remaining_to_rank = tied_teams.copy()
    ranked_list = []
    
    def apply_tiebreaker(criterion_func, tiebreaker_name: str) -> bool:
        """Apply a tiebreaker criterion and update rankings if it breaks any ties."""
        if len(remaining_to_rank) <= 1:
            return True
        
        # Calculate criterion for all remaining teams
        team_values = [(team, criterion_func(team)) for team in remaining_to_rank]
        team_values.sort(key=lambda x: x[1], reverse=True)
        
        # Group teams by criterion value
        best_value = team_values[0][1]
        best_teams = [team for team, value in team_values if value == best_value]
        
        if len(best_teams) == 1:
            # Clear winner
            ranked_list.append((best_teams[0], tiebreaker_name))
            remaining_to_rank.remove(best_teams[0])
            
            # NFL Rule: If remaining teams reduced to 2, restart with two-team format
            if len(remaining_to_rank) == 2:
                winner, tb = break_two_way_tie(
                    remaining_to_rank[0], remaining_to_rank[1],
                    all_h2h_records, all_div_records, all_conf_records,
                    {}, all_sov, all_sos, teams, results
                )
                loser = remaining_to_rank[1] if winner == remaining_to_rank[0] else remaining_to_rank[0]
                ranked_list.extend([(winner, tb), (loser, tb)])
                remaining_to_rank.clear()
                return True
            
            return False
        elif len(best_teams) < len(remaining_to_rank):
            # Partial tie break - some teams eliminated
            eliminated_teams = [team for team in remaining_to_rank if team not in best_teams]
            for team in eliminated_teams:
                remaining_to_rank.remove(team)
            
            # NFL Rule: If remaining teams reduced to 2, restart with two-team format
            if len(remaining_to_rank) == 2:
                winner, tb = break_two_way_tie(
                    remaining_to_rank[0], remaining_to_rank[1],
                    all_h2h_records, all_div_records, all_conf_records,
                    {}, all_sov, all_sos, teams, results
                )
                loser = remaining_to_rank[1] if winner == remaining_to_rank[0] else remaining_to_rank[0]
                ranked_list.extend([(winner, tb), (loser, tb)])
                remaining_to_rank.clear()
                return True
            # NFL Rule: If 3 teams remain after elimination, restart at step 1 of three-team format
            elif len(remaining_to_rank) == 3:
                # Restart the multi-way tie process with the remaining 3 teams
                sub_results = break_multi_way_tie(
                    remaining_to_rank, all_h2h_records, all_div_records, all_conf_records,
                    all_sov, all_sos, teams, results
                )
                ranked_list.extend(sub_results)
                remaining_to_rank.clear()
                return True
            
            return False
        
        # No tie broken at this level
        return False

    # (1) Head-to-head among tied teams
    if apply_tiebreaker(lambda t: _get_h2h_pct_among_tied(t, [x for x in remaining_to_rank if x != t], all_h2h_records), "h2h_among_tied"):
        return ranked_list

    # (2) Division record (only if all teams in same division)
    first_team_div = teams.filter(pl.col('team') == remaining_to_rank[0]).select('division').item()
    all_same_division = all(teams.filter(pl.col('team') == t).select('division').item() == first_team_div for t in remaining_to_rank)
    
    if all_same_division:
        if apply_tiebreaker(lambda t: _get_div_pct(t, all_div_records), "division_record_pct"):
            return ranked_list

    # (3) Common games record
    if apply_tiebreaker(lambda t: _get_common_games_pct(t, [x for x in remaining_to_rank if x != t], results), "common_games_pct"):
        return ranked_list

    # (4) Conference record
    if apply_tiebreaker(lambda t: _get_conf_pct(t, all_conf_records), "conference_record_pct"):
        return ranked_list

    # (5) Strength of victory
    if apply_tiebreaker(lambda t: all_sov.get(t, 0.0), "strength_of_victory"):
        return ranked_list

    # (6) Strength of schedule
    if apply_tiebreaker(lambda t: all_sos.get(t, 0.0), "strength_of_schedule"):
        return ranked_list

    # Final fallback - random order
    final_sort = sorted(remaining_to_rank)
    ranked_list.extend([(t, "coin_toss") for t in final_sort])
    
    return ranked_list

def model(dbt, sess):
    # Get data and use StringCache + Categoricals for fast joins
    with pl.StringCache():
        simulator = pl.from_pandas(dbt.ref("nfl_reg_season_simulator").df()).select([
            "scenario_id", "home_team", "visiting_team", "winning_team"
        ]).with_columns([
            pl.col("home_team").cast(pl.Categorical),
            pl.col("visiting_team").cast(pl.Categorical), 
            pl.col("winning_team").cast(pl.Categorical)
        ])
        
        teams = pl.from_pandas(dbt.ref("nfl_ratings").df()).select([
            "team", "conf", "division"
        ]).with_columns([
            pl.col("team").cast(pl.Categorical),
            pl.col("conf").cast(pl.Categorical),
            pl.col("division").cast(pl.Categorical)
        ])
        
        # Create long-form table: one row per (scenario_id, team, win_flag)
        # This eliminates all Python loops and iter_rows()
        long_table = pl.concat([
            # Home team perspective
            simulator.select([
                "scenario_id",
                pl.col("home_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("home_team")).then(1).otherwise(0).alias("wins"),
                pl.lit(1).alias("games")
            ]),
            # Visiting team perspective  
            simulator.select([
                "scenario_id", 
                pl.col("visiting_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("visiting_team")).then(1).otherwise(0).alias("wins"),
                pl.lit(1).alias("games")
            ])
        ])
        
        # Calculate team records in one aggregation
        team_records = long_table.group_by(["scenario_id", "team"]).agg([
            pl.sum("wins").alias("wins"),
            pl.sum("games").alias("games")
        ]).with_columns([
            (pl.col("games") - pl.col("wins")).alias("losses")
        ])
        
        # Join team metadata once
        standings = team_records.join(teams, on="team", how="left")
        
        # Pre-calculate H2H records for tiebreaking
        h2h_results = simulator.with_columns([
            pl.min_horizontal(pl.col("home_team"), pl.col("visiting_team")).alias("team1"),
            pl.max_horizontal(pl.col("home_team"), pl.col("visiting_team")).alias("team2"),
            pl.when(pl.col("winning_team") == pl.min_horizontal(pl.col("home_team"), pl.col("visiting_team"))).then(1).otherwise(0).alias("team1_won"),
            pl.when(pl.col("winning_team") == pl.max_horizontal(pl.col("home_team"), pl.col("visiting_team"))).then(1).otherwise(0).alias("team2_won")
        ])
        
        h2h_summary = h2h_results.group_by(["scenario_id", "team1", "team2"]).agg([
            pl.sum("team1_won").alias("team1_wins"),
            pl.sum("team2_won").alias("team2_wins")
        ])
        
        # Pre-calculate common games performance (used when H2H is tied or N/A)
        # Common games = games against the same opponents
        def calculate_common_games(tied_teams_df, games_data):
            """Calculate common games win percentage for tied teams"""
            # Get all opponents each team played against
            team_opponents = pl.concat([
                games_data.select([
                    "scenario_id", 
                    pl.col("home_team").alias("team"),
                    pl.col("visiting_team").alias("opponent"),
                    pl.when(pl.col("winning_team") == pl.col("home_team")).then(1).otherwise(0).alias("won")
                ]),
                games_data.select([
                    "scenario_id", 
                    pl.col("visiting_team").alias("team"),
                    pl.col("home_team").alias("opponent"),
                    pl.when(pl.col("winning_team") == pl.col("visiting_team")).then(1).otherwise(0).alias("won")
                ])
            ])
            
            # Find common opponents for tied teams within each conference
            tied_opponents = tied_teams_df.join(
                team_opponents, on=["scenario_id", "team"], how="inner"
            ).select(["scenario_id", "conf", "team", "opponent", "won"])
            
            # Group by scenario/conf/opponent to find which opponents are common to multiple tied teams
            common_opponents = tied_opponents.group_by(["scenario_id", "conf", "opponent"]).agg([
                pl.col("team").n_unique().alias("teams_played_opponent")
            ]).join(
                tied_teams_df.group_by(["scenario_id", "conf"]).agg([
                    pl.col("team").count().alias("total_tied_teams")
                ]), on=["scenario_id", "conf"]
            ).filter(pl.col("teams_played_opponent") >= 2)  # At least 2 tied teams played this opponent
            
            # Calculate common games record for each tied team
            common_games_performance = tied_opponents.join(
                common_opponents.select(["scenario_id", "conf", "opponent"]),
                on=["scenario_id", "conf", "opponent"], how="inner"
            ).group_by(["scenario_id", "conf", "team"]).agg([
                pl.sum("won").alias("common_wins"),
                pl.count().alias("common_games")
            ]).with_columns([
                (pl.col("common_wins") / (pl.col("common_games") + 1e-10)).alias("common_pct")
            ])
            
            return common_games_performance
        
        # Calculate strength of victory (sum of win percentages of defeated teams)
        def calculate_strength_of_victory(tied_teams_df, games_data, team_records_df):
            """Calculate strength of victory for tied teams"""
            # Get all teams each tied team defeated
            team_victories = pl.concat([
                games_data.filter(pl.col("winning_team") == pl.col("home_team")).select([
                    "scenario_id", 
                    pl.col("home_team").alias("team"),
                    pl.col("visiting_team").alias("defeated_team")
                ]),
                games_data.filter(pl.col("winning_team") == pl.col("visiting_team")).select([
                    "scenario_id", 
                    pl.col("visiting_team").alias("team"),
                    pl.col("home_team").alias("defeated_team")
                ])
            ])
            
            # Join with tied teams to only calculate for teams that need it
            tied_victories = tied_teams_df.join(
                team_victories, on=["scenario_id", "team"], how="inner"
            )
            
            # Get the win percentage of each defeated team
            defeated_team_records = team_records_df.with_columns([
                (pl.col("wins") / pl.col("games")).alias("defeated_team_pct")
            ]).select(["scenario_id", "team", "defeated_team_pct"]).rename({"team": "defeated_team"})
            
            # Calculate strength of victory as sum of defeated teams' win percentages
            strength_of_victory = tied_victories.join(
                defeated_team_records, on=["scenario_id", "defeated_team"], how="left"
            ).group_by(["scenario_id", "conf", "team"]).agg([
                pl.sum("defeated_team_pct").alias("strength_of_victory"),
                pl.count().alias("victories_count")
            ]).with_columns([
                # Normalize by number of victories to get average opponent strength
                (pl.col("strength_of_victory") / (pl.col("victories_count") + 1e-10)).alias("avg_defeated_pct")
            ])
            
            return strength_of_victory
        
        # Pre-calculate division and conference records
        games_with_teams = simulator.join(
            teams.rename({'conf': 'home_conf', 'division': 'home_division'}), 
            left_on='home_team', right_on='team'
        ).join(
            teams.rename({'conf': 'visiting_conf', 'division': 'visiting_division'}), 
            left_on='visiting_team', right_on='team'
        )
        
        # Division records
        div_records = pl.concat([
            games_with_teams.filter(pl.col('home_division') == pl.col('visiting_division')).select([
                "scenario_id",
                pl.col("home_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("home_team")).then(1).otherwise(0).alias("wins"),
                pl.when(pl.col("winning_team") != pl.col("home_team")).then(1).otherwise(0).alias("losses")
            ]),
            games_with_teams.filter(pl.col('home_division') == pl.col('visiting_division')).select([
                "scenario_id",
                pl.col("visiting_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("visiting_team")).then(1).otherwise(0).alias("wins"),
                pl.when(pl.col("winning_team") != pl.col("visiting_team")).then(1).otherwise(0).alias("losses")
            ])
        ]).group_by(["scenario_id", "team"]).agg([
            pl.sum("wins").alias("div_wins"),
            pl.sum("losses").alias("div_losses")
        ])
        
        # Conference records  
        conf_records = pl.concat([
            games_with_teams.filter(pl.col('home_conf') == pl.col('visiting_conf')).select([
                "scenario_id",
                pl.col("home_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("home_team")).then(1).otherwise(0).alias("wins"),
                pl.when(pl.col("winning_team") != pl.col("home_team")).then(1).otherwise(0).alias("losses")
            ]),
            games_with_teams.filter(pl.col('home_conf') == pl.col('visiting_conf')).select([
                "scenario_id",
                pl.col("visiting_team").alias("team"),
                pl.when(pl.col("winning_team") == pl.col("visiting_team")).then(1).otherwise(0).alias("wins"),
                pl.when(pl.col("winning_team") != pl.col("visiting_team")).then(1).otherwise(0).alias("losses")
            ])
        ]).group_by(["scenario_id", "team"]).agg([
            pl.sum("wins").alias("conf_wins"),
            pl.sum("losses").alias("conf_losses")
        ])
        
        # --- Simple Division Winner and Wildcard Logic ---
        
        # Step 1: Identify division winners using proper division tiebreaker sequence
        # Join division and conference records for tiebreaking
        standings_with_tiebreakers = standings.join(
            div_records, on=["scenario_id", "team"], how="left"
        ).join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("div_wins").fill_null(0) / (pl.col("div_wins").fill_null(0) + pl.col("div_losses").fill_null(0) + 1e-10)).alias("div_pct"),
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct")
        ])
        
        # Calculate strength of schedule for division tiebreakers
        def calculate_strength_of_schedule_simple(teams_df, games_data, team_records_df):
            """Calculate strength of schedule (combined win% of all opponents)"""
            # Get all opponents each team played against
            team_opponents = pl.concat([
                games_data.select([
                    "scenario_id", 
                    pl.col("home_team").alias("team"),
                    pl.col("visiting_team").alias("opponent")
                ]),
                games_data.select([
                    "scenario_id", 
                    pl.col("visiting_team").alias("team"),
                    pl.col("home_team").alias("opponent")
                ])
            ])
            
            # Join with teams of interest
            team_opps = teams_df.join(
                team_opponents, on=["scenario_id", "team"], how="inner"
            ).select(["scenario_id", "conf", "team", "opponent"])
            
            # Get opponent win percentages
            opponent_records = team_records_df.with_columns([
                (pl.col("wins") / pl.col("games")).alias("opp_pct")
            ]).select(["scenario_id", "team", "opp_pct"]).rename({"team": "opponent"})
            
            # Calculate average opponent strength
            sos = team_opps.join(
                opponent_records, on=["scenario_id", "opponent"], how="left"
            ).group_by(["scenario_id", "conf", "team"]).agg([
                pl.mean("opp_pct").alias("strength_of_schedule")
            ])
            
            return sos

        # Calculate strength of schedule for division winner determination
        div_sos = calculate_strength_of_schedule_simple(standings, simulator, team_records)
        
        standings_with_tiebreakers_sos = standings_with_tiebreakers.join(
            div_sos, on=["scenario_id", "conf", "team"], how="left"
        )
        
        # Apply proper division tiebreaker sequence to determine division winners
        # NFL Rules: 1. Wins, 2. H2H, 3. Div Record, 4. Common Games, 5. Conf Record, 6. SOV, 7. SOS
        division_winners = standings_with_tiebreakers_sos.with_columns([
            pl.struct([
                pl.col("wins"),
                pl.lit(0.5).alias("h2h_placeholder"),  # H2H placeholder (calculated properly in detailed tiebreaker)
                pl.col("div_pct"),
                pl.lit(0.5).alias("common_placeholder"),  # Common games placeholder (calculated properly in detailed tiebreaker)
                pl.col("conf_pct"),
                pl.lit(0.5).alias("sov_placeholder"),  # SOV placeholder (calculated properly in detailed tiebreaker)
                pl.col("strength_of_schedule").fill_null(0.5),
                pl.col("team").cast(pl.String)
            ]).rank(method="ordinal", descending=True).over(["scenario_id", "conf", "division"]).alias("div_rank")
        ]).filter(pl.col("div_rank") == 1)
        
        # Step 2: Apply proper tiebreakers for division winner seeding (1-4)
        
        # Check for ties among division winners within each conference
        div_winner_tie_check = division_winners.group_by(["scenario_id", "conf"]).agg([
            pl.col("wins").n_unique().alias("unique_wins"),
            pl.col("team").count().alias("total_div_winners")
        ])
        
        # Fast path: No ties among division winners (all have different records)
        clear_div_winners = division_winners.join(
            div_winner_tie_check.filter(pl.col("unique_wins") == pl.col("total_div_winners")),
            on=["scenario_id", "conf"],
            how="inner"
        ).with_columns([
            pl.col("wins").rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("rank"),
            pl.col("conf").alias("conference"),
            pl.lit("wins").alias("tiebreaker_used")
        ])
        
        # Detailed path: Ties among division winners need NFL tiebreaking
        tied_div_winners = division_winners.join(
            div_winner_tie_check.filter(pl.col("unique_wins") < pl.col("total_div_winners")),
            on=["scenario_id", "conf"],
            how="inner"
        )
        
        # Apply NFL division winner tiebreaking sequence
        tied_resolved = tied_div_winners.join(
            div_records, on=["scenario_id", "team"], how="left"
        ).join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("div_wins").fill_null(0) / (pl.col("div_wins").fill_null(0) + pl.col("div_losses").fill_null(0) + 1e-10)).alias("div_pct"),
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct")
        ])
        
        # Calculate H2H performance for each team against other tied teams in their conference
        def get_h2h_performance(tied_teams_df, h2h_data):
            """Calculate head-to-head win percentage for tied teams"""
            # Create all team pairs within each tied group (same wins only)
            tied_with_pairs = tied_teams_df.join(
                tied_teams_df.select(["scenario_id", "conf", "wins", pl.col("team").alias("opponent")]),
                on=["scenario_id", "conf", "wins"], how="inner"
            ).filter(pl.col("team") != pl.col("opponent"))
            
            # Create normalized team pairs for H2H lookup
            pairs_normalized = tied_with_pairs.with_columns([
                pl.min_horizontal(pl.col("team"), pl.col("opponent")).alias("team1"),
                pl.max_horizontal(pl.col("team"), pl.col("opponent")).alias("team2"),
                pl.col("team").alias("lookup_team")
            ])
            
            # Join with H2H results
            h2h_lookup = pairs_normalized.join(
                h2h_data, on=["scenario_id", "team1", "team2"], how="left"
            ).with_columns([
                # Determine if lookup_team is team1 or team2, get their wins
                pl.when(pl.col("lookup_team") == pl.col("team1"))
                .then(pl.col("team1_wins").fill_null(0))
                .otherwise(pl.col("team2_wins").fill_null(0))
                .alias("h2h_wins"),
                
                # Total games = team1_wins + team2_wins
                (pl.col("team1_wins").fill_null(0) + pl.col("team2_wins").fill_null(0)).alias("h2h_games")
            ])
            
            # Aggregate H2H performance by team (within same win groups)
            h2h_performance = h2h_lookup.group_by(["scenario_id", "conf", "wins", "lookup_team"]).agg([
                pl.sum("h2h_wins").alias("h2h_wins"),
                pl.sum("h2h_games").alias("h2h_games")
            ]).with_columns([
                (pl.col("h2h_wins") / (pl.col("h2h_games") + 1e-10)).alias("h2h_pct")
            ]).rename({"lookup_team": "team"})
            
            return h2h_performance
        
        # Get H2H performance for tied division winners
        h2h_performance = get_h2h_performance(tied_div_winners, h2h_summary)
        
        # Get common games performance for tied division winners
        common_games_performance = calculate_common_games(tied_div_winners, simulator)
        
        # Get strength of victory for tied division winners
        strength_of_victory_performance = calculate_strength_of_victory(tied_div_winners, simulator, team_records)
        
        # Create a tiebreaker score for ranking tied division winners
        tied_ranked = tied_resolved.join(
            h2h_performance, on=["scenario_id", "conf", "wins", "team"], how="left"
        ).join(
            common_games_performance, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            strength_of_victory_performance, on=["scenario_id", "conf", "team"], how="left"
        ).with_columns([
            # NFL Division Winner Tiebreaker Sequence:
            # 1. Overall record (already tied)
            # 2. Head-to-head win percentage against tied teams
            # 3. Division record percentage
            # 4. Common games win percentage
            # 5. Conference record percentage
            # 6. Strength of victory (avg win % of defeated teams)
            # 7. Team name for determinism
            pl.struct([
                pl.col("wins"),
                pl.col("h2h_pct").fill_null(0.5),  # 50% if no H2H games
                pl.col("div_pct"),
                pl.col("common_pct").fill_null(0.5),  # 50% if no common games
                pl.col("conf_pct"),
                pl.col("avg_defeated_pct").fill_null(0.5),  # 50% if no victories
                pl.col("team").cast(pl.String)
            ]).rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("rank")
        ]).with_columns([
            pl.col("conf").alias("conference"),
            # Create informative tiebreaker descriptions showing actual results
            pl.when((pl.col("h2h_games").fill_null(0) > 0) & (pl.col("h2h_pct").fill_null(0.5) != 0.5))
            .then(pl.concat_str([
                pl.lit("head-to-head "),
                pl.col("h2h_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("h2h_games").fill_null(0) - pl.col("h2h_wins").fill_null(0)).cast(pl.String),
                pl.lit(" vs tied teams")
            ]))
            .when(pl.col("div_pct") > pl.lit(0.001))
            .then(pl.concat_str([
                pl.lit("division record "),
                pl.col("div_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                pl.col("div_losses").fill_null(0).cast(pl.String),
                pl.lit(" ("),
                (pl.col("div_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            .when((pl.col("common_games").fill_null(0) >= 4) & (pl.col("common_pct").fill_null(0.5) != 0.5))
            .then(pl.concat_str([
                pl.lit("common games "),
                pl.col("common_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("common_games").fill_null(0) - pl.col("common_wins").fill_null(0)).cast(pl.String),
                pl.lit(" ("),
                (pl.col("common_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            .when(pl.col("conf_pct") > pl.lit(0.001))
            .then(pl.concat_str([
                pl.lit("conference record "),
                pl.col("conf_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                pl.col("conf_losses").fill_null(0).cast(pl.String),
                pl.lit(" ("),
                (pl.col("conf_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            .when((pl.col("victories_count").fill_null(0) > 0) & (pl.col("avg_defeated_pct").fill_null(0.5) != 0.5))
            .then(pl.concat_str([
                pl.lit("strength of victory "),
                (pl.col("avg_defeated_pct") * 100).round(1).cast(pl.String),
                pl.lit("% avg opponent strength")
            ]))
            .otherwise(pl.lit("team name"))
            .alias("tiebreaker_used")
        ])
        
        # Determine actual tiebreaker used for tied division winners
        tied_ranked_with_proper_tiebreaker = tied_ranked.with_columns([
            # Determine which step in NFL sequence actually broke the tie
            # Step 1: Check if H2H breaks ties (only for teams that actually played)
            pl.when((pl.col("h2h_games").fill_null(0) > 0) & 
                   (pl.col("h2h_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("head-to-head "),
                pl.col("h2h_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("h2h_games").fill_null(0) - pl.col("h2h_wins").fill_null(0)).cast(pl.String),
                pl.lit(" vs tied teams")
            ]))
            # Step 2: Division record (only if teams in same division AND it differentiates)
            .when((pl.col("division").over(["scenario_id", "conf", "wins"]).n_unique() == 1) & 
                 (pl.col("div_pct").over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("division record "),
                pl.col("div_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                pl.col("div_losses").fill_null(0).cast(pl.String),
                pl.lit(" ("),
                (pl.col("div_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            # Step 3: Common games (min 4 games and differentiates)
            .when((pl.col("common_games").fill_null(0) >= 4) & 
                 (pl.col("common_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("common games "),
                pl.col("common_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("common_games").fill_null(0) - pl.col("common_wins").fill_null(0)).cast(pl.String),
                pl.lit(" ("),
                (pl.col("common_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            # Step 4: Conference record
            .when(pl.col("conf_pct").over(["scenario_id", "conf", "wins"]).n_unique() > 1)
            .then(pl.concat_str([
                pl.lit("conference record "),
                pl.col("conf_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                pl.col("conf_losses").fill_null(0).cast(pl.String),
                pl.lit(" ("),
                (pl.col("conf_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            # Step 5: Strength of victory
            .when((pl.col("victories_count").fill_null(0) > 0) & 
                 (pl.col("avg_defeated_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("strength of victory "),
                (pl.col("avg_defeated_pct") * 100).round(1).cast(pl.String),
                pl.lit("% avg opponent strength")
            ]))
            .otherwise(pl.lit("team name"))
            .alias("tiebreaker_used")
        ])

        # Combine all division winner rankings
        div_winners_ranked = pl.concat([
            clear_div_winners.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            tied_ranked_with_proper_tiebreaker.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"])
        ])
        
        # Step 3: Wildcard seeding (5-7) - Apply proper NFL wildcard tiebreaking
        # First get all non-division winners
        all_non_div_winners = standings.join(
            division_winners.select(["scenario_id", "team"]), 
            on=["scenario_id", "team"], 
            how="anti"
        )
        
        # Apply division tiebreaker to eliminate all but highest ranked club in each division
        # For wildcard consideration, use same tiebreakers as division winners but only keep #1 from each division
        non_div_winners_with_tiebreakers = all_non_div_winners.join(
            div_records, on=["scenario_id", "team"], how="left"
        ).join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("div_wins").fill_null(0) / (pl.col("div_wins").fill_null(0) + pl.col("div_losses").fill_null(0) + 1e-10)).alias("div_pct"),
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct")
        ])
        
        # Calculate strength of schedule for wildcard pre-elimination
        wildcard_sos = calculate_strength_of_schedule_simple(non_div_winners_with_tiebreakers, simulator, team_records)
        
        non_div_winners_with_sos = non_div_winners_with_tiebreakers.join(
            wildcard_sos, on=["scenario_id", "conf", "team"], how="left"
        )
        
        # For wildcards, we consider ALL non-division winners, not just top from each division
        # NFL wildcard rule: Best non-division winners regardless of division
        wildcard_candidates = non_div_winners_with_sos
        
        # Check for ties among wildcard candidates within each conference
        wildcard_tie_check = wildcard_candidates.group_by(["scenario_id", "conf"]).agg([
            pl.col("wins").n_unique().alias("unique_wins"),
            pl.col("team").count().alias("total_candidates")
        ])
        
        # Fast path: No ties among top wildcard candidates (all have different records)
        clear_wildcards = wildcard_candidates.join(
            wildcard_tie_check.filter(pl.col("unique_wins") == pl.col("total_candidates")),
            on=["scenario_id", "conf"],
            how="inner"
        ).with_columns([
            pl.col("wins").rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("wildcard_rank")
        ]).filter(pl.col("wildcard_rank") <= 3).with_columns([
            (pl.col("wildcard_rank") + 4).alias("rank"),
            pl.col("conf").alias("conference"),
            pl.lit("wins").alias("tiebreaker_used")
        ])
        
        # Detailed path: Ties among wildcard candidates need NFL tiebreaking
        tied_wildcard_candidates = wildcard_candidates.join(
            wildcard_tie_check.filter(pl.col("unique_wins") < pl.col("total_candidates")),
            on=["scenario_id", "conf"],
            how="inner"
        )
        
        # Apply NFL wildcard tiebreaking sequence (different from division winner rules)
        tied_wildcard_resolved = tied_wildcard_candidates.join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct")
        ])
        
        # Get H2H performance for tied wildcard candidates (when applicable)
        wildcard_h2h_performance = get_h2h_performance(tied_wildcard_candidates, h2h_summary)
        
        # Get common games performance for tied wildcard candidates
        wildcard_common_games_performance = calculate_common_games(tied_wildcard_candidates, simulator)
        
        # Get strength of victory for tied wildcard candidates
        wildcard_strength_of_victory_performance = calculate_strength_of_victory(tied_wildcard_candidates, simulator, team_records)
        
        # Get strength of schedule for tied wildcard candidates
        wildcard_strength_of_schedule_performance = calculate_strength_of_schedule_simple(tied_wildcard_candidates, simulator, team_records)
        
        # Create wildcard ranking with proper NFL tiebreaker sequence
        tied_wildcard_ranked = tied_wildcard_resolved.join(
            wildcard_h2h_performance, on=["scenario_id", "conf", "wins", "team"], how="left"
        ).join(
            wildcard_common_games_performance, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            wildcard_strength_of_victory_performance, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            wildcard_strength_of_schedule_performance, on=["scenario_id", "conf", "team"], how="left"
        ).with_columns([
            # NFL Wildcard Tiebreaker Sequence (for teams from different divisions):
            # 1. Overall record (already tied in most cases)
            # 2. Head-to-head (if applicable - only when teams actually played)
            # 3. Conference record percentage
            # 4. Common games win percentage (min 4 games required)
            # 5. Strength of victory (avg win % of defeated teams)
            # 6. Strength of schedule (avg win % of all opponents)
            # 7. Team name for determinism
            pl.struct([
                pl.col("wins"),
                # Only use H2H if teams actually played (h2h_games > 0), otherwise neutral
                pl.when(pl.col("h2h_games").fill_null(0) > 0)
                .then(pl.col("h2h_pct"))
                .otherwise(pl.lit(0.5)).alias("h2h_pct_adj"),
                pl.col("conf_pct"),
                # Only use common games percentage if minimum 4 games, otherwise neutral
                pl.when(pl.col("common_games").fill_null(0) >= 4)
                .then(pl.col("common_pct"))
                .otherwise(pl.lit(0.5)).alias("common_pct_adj"),
                pl.col("avg_defeated_pct").fill_null(0.5),  # 50% if no victories
                pl.col("strength_of_schedule").fill_null(0.5),  # 50% if no schedule data
                pl.col("team").cast(pl.String)
            ]).rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("wildcard_rank")
        ]).filter(pl.col("wildcard_rank") <= 3).with_columns([
            (pl.col("wildcard_rank") + 4).alias("rank"),
            pl.col("conf").alias("conference")
        ])
        
        # Apply proper tiebreaker descriptions for wildcard seeding
        tied_wildcard_ranked_with_proper_tiebreaker = tied_wildcard_ranked.with_columns([
            # Determine which step in NFL wildcard sequence actually broke the tie
            pl.when((pl.col("h2h_games").fill_null(0) > 0) & 
                   (pl.col("h2h_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("head-to-head "),
                pl.col("h2h_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("h2h_games").fill_null(0) - pl.col("h2h_wins").fill_null(0)).cast(pl.String),
                pl.lit(" vs tied teams")
            ]))
            .when(pl.col("conf_pct").over(["scenario_id", "conf", "wins"]).n_unique() > 1)
            .then(pl.concat_str([
                pl.lit("conference record "),
                pl.col("conf_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                pl.col("conf_losses").fill_null(0).cast(pl.String),
                pl.lit(" ("),
                (pl.col("conf_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            .when((pl.col("common_games").fill_null(0) >= 4) & 
                 (pl.col("common_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("common games "),
                pl.col("common_wins").fill_null(0).cast(pl.String),
                pl.lit("-"),
                (pl.col("common_games").fill_null(0) - pl.col("common_wins").fill_null(0)).cast(pl.String),
                pl.lit(" ("),
                (pl.col("common_pct") * 100).round(1).cast(pl.String),
                pl.lit("%)")
            ]))
            .when((pl.col("victories_count").fill_null(0) > 0) & 
                 (pl.col("avg_defeated_pct").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1))
            .then(pl.concat_str([
                pl.lit("strength of victory "),
                (pl.col("avg_defeated_pct") * 100).round(1).cast(pl.String),
                pl.lit("% avg opponent strength")
            ]))
            .when(pl.col("strength_of_schedule").fill_null(0.5).over(["scenario_id", "conf", "wins"]).n_unique() > 1)
            .then(pl.concat_str([
                pl.lit("strength of schedule "),
                (pl.col("strength_of_schedule") * 100).round(1).cast(pl.String),
                pl.lit("% avg opponent strength")
            ]))
            .otherwise(pl.lit("team name"))
            .alias("tiebreaker_used")
        ])
        
        # Combine all wildcard rankings
        wildcards = pl.concat([
            clear_wildcards.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            tied_wildcard_ranked_with_proper_tiebreaker.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"])
        ])
        
        # Get remaining teams that missed playoffs
        playoff_teams = pl.concat([
            div_winners_ranked.select(["scenario_id", "team"]),
            wildcards.select(["scenario_id", "team"])
        ])
        
        non_playoff = standings.join(
            playoff_teams,
            on=["scenario_id", "team"],
            how="anti"
        ).with_columns([
            pl.col("wins").rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("remaining_rank")
        ]).with_columns([
            (pl.col("remaining_rank") + 7).alias("rank"),
            pl.col("conf").alias("conference"), 
            # Better tiebreaker description for non-playoff teams
            pl.when(pl.col("wins").over(["scenario_id", "conf"]).n_unique() > 1)
            .then(pl.concat_str([
                pl.lit("wins ("),
                pl.col("wins").cast(pl.String),
                pl.lit("-"),
                (pl.col("games") - pl.col("wins")).cast(pl.String),
                pl.lit(")")
            ]))
            .otherwise(pl.lit("team name"))
            .alias("tiebreaker_used")
        ])
        
        # Combine all results
        final_result = pl.concat([
            div_winners_ranked.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            wildcards.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            non_playoff.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"])
        ]).sort(["scenario_id", "conference", "rank"])
        
        # Convert categoricals back to strings for pandas compatibility
        final_result = final_result.with_columns([
            pl.col("team").cast(pl.String),
            pl.col("conference").cast(pl.String),
            pl.col("tiebreaker_used").cast(pl.String)
        ])
    
    return final_result.to_pandas()
