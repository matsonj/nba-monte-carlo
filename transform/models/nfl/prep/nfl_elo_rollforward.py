import pandas as pd
import math

def calc_elo_diff(game_result: float, home_elo: float, visiting_elo: float, home_adv: float, scoring_margin: float) -> float:
    # just need to make sure i really get a game result that is float (annoying)
    game_result = float(game_result)
    adj_home_elo = float(home_elo) + float(home_adv)
    winner_elo_diff = visiting_elo - adj_home_elo if game_result == 1 else adj_home_elo - visiting_elo
    margin_of_victory_multiplier = math.log(abs(scoring_margin)+1)*(2.2/(winner_elo_diff*0.001+2.2))
    return 20.0 * (( game_result ) - (1.0 / (10.0 ** (-(visiting_elo - home_elo - home_adv) / 400.0) + 1.0))) * margin_of_victory_multiplier

def model(dbt, sess):
    # get the existing elo ratings for the teams
    home_adv = dbt.config.get("nfl_elo_offset",52.0)
    team_ratings = dbt.ref("nfl_raw_team_ratings").df()
    original_elo = dict(zip(team_ratings["team"], team_ratings["elo_rating"].astype(float)))
    working_elo = original_elo.copy()

    # loop over the historical game data and update the elo ratings as we go
    nba_elo_latest = (dbt.ref("nfl_latest_results")
        .project("game_id, visiting_team, home_team, winning_team, game_result,neutral_site,margin")
        .order("game_id")
    )
    nba_elo_latest.execute()
    columns = ["game_id", "visiting_team", "visiting_team_elo_rating", "home_team", "home_team_elo_rating", "winning_team", "elo_change","margin"]
    rows = []
    for (game_id, vteam, hteam, winner, game_result,neutral_site,margin) in nba_elo_latest.fetchall():
        helo, velo = working_elo[hteam], working_elo[vteam]
        elo_change = calc_elo_diff(game_result, helo, velo, 0 if neutral_site == 1 else home_adv,margin)
        rows.append((game_id, vteam, velo, hteam, helo, winner, elo_change,margin))
        working_elo[hteam] -= elo_change
        working_elo[vteam] += elo_change

    return pd.DataFrame(columns=columns, data=rows)