import pandas as pd

def calc_elo_diff(game_result: int, home_elo: float, visiting_elo: float) -> float:
    return 25.0 * (( game_result ) - (1.0 / (10.0 ** (-(visiting_elo - home_elo - 70) / 400.0) + 1.0)))

def model(dbt, sess):
    # get the existing elo ratings for the teams
    team_ratings = dbt.ref("ncaaf_prep_team_ratings").df()
    original_elo = dict(zip(team_ratings["team"], team_ratings["elo_rating"].astype(float)))
    working_elo = original_elo.copy()
    return pd.DataFrame(team_ratings)