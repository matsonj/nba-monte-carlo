import pandas as pd

def calc_elo_diff(game_result: int, home_elo: float, visiting_elo: float) -> float:
    return 150.0 * (( game_result ) - (1.0 / (10.0 ** (-(visiting_elo - home_elo - 70) / 400.0) + 1.0)))

def model(dbt, sess):
    # get the existing elo ratings for the teams
    team_ratings = dbt.ref("ncaaf_prep_team_ratings").df()
    original_elo = dict(zip(team_ratings["team"], team_ratings["elo_rating"].astype(float)))
    working_elo = original_elo.copy()

    # loop over the historical game data and update the elo ratings as we go
    nba_elo_latest = (dbt.ref("ncaaf_latest_results")
        .project("game_id, visiting_team, home_team, winning_team, game_result")
        .order("game_id")
    )
    nba_elo_latest.execute()
    columns = ["game_id", "visiting_team", "visiting_team_elo_rating", "home_team", "home_team_elo_rating", "winning_team", "elo_change"]
    rows = []
    for (game_id, vteam, hteam, winner, game_result) in nba_elo_latest.fetchall():
        helo, velo = working_elo[hteam], working_elo[vteam]
        elo_change =  calc_elo_diff(game_result, helo, velo)
        rows.append((game_id, vteam, velo, hteam, helo, winner, elo_change))
        working_elo[hteam] -= elo_change
        working_elo[vteam] += elo_change

    return pd.DataFrame(columns=columns, data=rows)


# This part is user provided model code
# you will need to copy the next section to run the code
# COMMAND ----------
# this part is dbt logic for get ref work, do not modify

def ref(*args, **kwargs):
    refs = {"ncaaf_latest_results": "\"mdsbox\".\"main\".\"ncaaf_latest_results\"", "ncaaf_prep_team_ratings": "\"mdsbox\".\"main\".\"ncaaf_prep_team_ratings\""}
    key = '.'.join(args)
    version = kwargs.get("v") or kwargs.get("version")
    if version:
        key += f".v{version}"
    dbt_load_df_function = kwargs.get("dbt_load_df_function")
    return dbt_load_df_function(refs[key])


def source(*args, dbt_load_df_function):
    sources = {}
    key = '.'.join(args)
    return dbt_load_df_function(sources[key])


config_dict = {}


class config:
    def __init__(self, *args, **kwargs):
        pass

    @staticmethod
    def get(key, default=None):
        return config_dict.get(key, default)

class this:
    """dbt.this() or dbt.this.identifier"""
    database = "mdsbox"
    schema = "main"
    identifier = "ncaaf_elo_rollforward"
    
    def __repr__(self):
        return '"mdsbox"."main"."ncaaf_elo_rollforward"'


class dbtObj:
    def __init__(self, load_df_function) -> None:
        self.source = lambda *args: source(*args, dbt_load_df_function=load_df_function)
        self.ref = lambda *args, **kwargs: ref(*args, **kwargs, dbt_load_df_function=load_df_function)
        self.config = config
        self.this = this()
        self.is_incremental = False

# COMMAND ----------


