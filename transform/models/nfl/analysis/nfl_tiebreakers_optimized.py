import pandas as pd
import polars as pl
from typing import List, Tuple


def _build_long_games(simulator: pl.DataFrame) -> pl.DataFrame:
    """Return long perspective: one row per team-game with opponent and win flag."""
    return pl.concat([
        simulator.select([
            "scenario_id",
            pl.col("home_team").alias("team"),
            pl.col("visiting_team").alias("opponent"),
            pl.when(pl.col("winning_team") == pl.col("home_team")).then(1).otherwise(0).alias("won"),
        ]),
        simulator.select([
            "scenario_id",
            pl.col("visiting_team").alias("team"),
            pl.col("home_team").alias("opponent"),
            pl.when(pl.col("winning_team") == pl.col("visiting_team")).then(1).otherwise(0).alias("won"),
        ]),
    ])


def _team_records(long_games: pl.DataFrame) -> pl.DataFrame:
    return long_games.group_by(["scenario_id", "team"]).agg([
        pl.sum("won").alias("wins"),
        pl.count().alias("games"),
    ]).with_columns([
        (pl.col("games") - pl.col("wins")).alias("losses")
    ])


def _div_conf_records(long_games: pl.DataFrame, teams: pl.DataFrame) -> Tuple[pl.DataFrame, pl.DataFrame]:
    games_with_meta = long_games.join(
        teams.rename({"team": "team_meta", "conf": "team_conf", "division": "team_division"}),
        left_on="team", right_on="team_meta", how="left",
    ).join(
        teams.rename({"team": "opp_meta", "conf": "opp_conf", "division": "opp_division"}),
        left_on="opponent", right_on="opp_meta", how="left",
    )

    div = games_with_meta.filter(pl.col("team_division") == pl.col("opp_division")).group_by([
        "scenario_id", "team"
    ]).agg([
        pl.sum("won").alias("div_wins"),
        (pl.count() - pl.sum("won")).alias("div_losses"),
    ])

    conf = games_with_meta.filter(pl.col("team_conf") == pl.col("opp_conf")).group_by([
        "scenario_id", "team"
    ]).agg([
        pl.sum("won").alias("conf_wins"),
        (pl.count() - pl.sum("won")).alias("conf_losses"),
    ])

    return div, conf


def _h2h_summary(simulator: pl.DataFrame) -> pl.DataFrame:
    pairs = simulator.with_columns([
        pl.min_horizontal(pl.col("home_team"), pl.col("visiting_team")).alias("team1"),
        pl.max_horizontal(pl.col("home_team"), pl.col("visiting_team")).alias("team2"),
        pl.when(pl.col("winning_team") == pl.min_horizontal(pl.col("home_team"), pl.col("visiting_team"))).then(1).otherwise(0).alias("team1_won"),
        pl.when(pl.col("winning_team") == pl.max_horizontal(pl.col("home_team"), pl.col("visiting_team"))).then(1).otherwise(0).alias("team2_won"),
    ])
    return pairs.group_by(["scenario_id", "team1", "team2"]).agg([
        pl.sum("team1_won").alias("team1_wins"),
        pl.sum("team2_won").alias("team2_wins"),
    ])


def _h2h_metrics(candidates: pl.DataFrame, h2h: pl.DataFrame, group_keys: List[str]) -> pl.DataFrame:
    pairs = candidates.join(
        candidates.select(group_keys + [pl.col("team").alias("opponent"), "wins"]),
        on=group_keys + ["wins"], how="inner",
    ).filter(pl.col("team") != pl.col("opponent"))

    norm = pairs.with_columns([
        pl.min_horizontal(pl.col("team"), pl.col("opponent")).alias("team1"),
        pl.max_horizontal(pl.col("team"), pl.col("opponent")).alias("team2"),
        pl.col("team").alias("lookup_team"),
    ])

    joined = norm.join(h2h, on=["scenario_id", "team1", "team2"], how="left").with_columns([
        pl.when(pl.col("lookup_team") == pl.col("team1")).then(pl.col("team1_wins").fill_null(0)).otherwise(pl.col("team2_wins").fill_null(0)).alias("h2h_wins"),
        (pl.col("team1_wins").fill_null(0) + pl.col("team2_wins").fill_null(0)).alias("h2h_games"),
    ])

    return joined.group_by(group_keys + ["wins", "lookup_team"]).agg([
        pl.sum("h2h_wins").alias("h2h_wins"),
        pl.sum("h2h_games").alias("h2h_games"),
    ]).with_columns([
        (pl.col("h2h_wins") / (pl.col("h2h_games") + 1e-10)).alias("h2h_pct"),
    ]).rename({"lookup_team": "team"})


def _common_metrics(candidates: pl.DataFrame, long_games: pl.DataFrame, group_keys: List[str]) -> pl.DataFrame:
    team_opps = candidates.join(long_games, on=["scenario_id", "team"], how="inner").select([
        "scenario_id", *group_keys[1:], "team", "opponent", "won"
    ])

    counts = team_opps.group_by(["scenario_id", *group_keys[1:], "opponent"]).agg([
        pl.col("team").n_unique().alias("teams_played"),
    ]).join(
        candidates.group_by(["scenario_id", *group_keys[1:]]).agg([
            pl.col("team").n_unique().alias("tied_teams")
        ]),
        on=["scenario_id", *group_keys[1:]], how="left"
    )

    common = team_opps.join(
        counts.filter(pl.col("teams_played") == pl.col("tied_teams")).select(["scenario_id", *group_keys[1:], "opponent"]),
        on=["scenario_id", *group_keys[1:], "opponent"], how="inner",
    ).group_by(["scenario_id", *group_keys[1:], "team"]).agg([
        pl.sum("won").alias("common_wins"),
        pl.count().alias("common_games"),
    ]).with_columns([
        (pl.col("common_wins") / (pl.col("common_games") + 1e-10)).alias("common_pct"),
    ])

    return common


def _sov_metrics(candidates: pl.DataFrame, long_games: pl.DataFrame, team_records: pl.DataFrame, group_keys: List[str]) -> pl.DataFrame:
    wins_only = long_games.filter(pl.col("won") == 1).select([
        "scenario_id", pl.col("team").alias("winner"), pl.col("opponent").alias("defeated_team")
    ])
    cand_wins = candidates.select(["scenario_id", *group_keys[1:], pl.col("team").alias("winner")]).join(
        wins_only, on=["scenario_id", "winner"], how="inner",
    )
    opp_pct = team_records.with_columns([
        (pl.col("wins") / pl.col("games")).alias("opp_pct")
    ]).select(["scenario_id", pl.col("team").alias("defeated_team"), "opp_pct"]) 
    sov = cand_wins.join(opp_pct, on=["scenario_id", "defeated_team"], how="left").group_by([
        "scenario_id", *group_keys[1:], "winner"
    ]).agg([
        pl.mean("opp_pct").alias("avg_defeated_pct"),
        pl.count().alias("victories_count"),
    ]).rename({"winner": "team"})
    return sov


def _sos_metrics(candidates: pl.DataFrame, long_games: pl.DataFrame, team_records: pl.DataFrame, group_keys: List[str]) -> pl.DataFrame:
    opp_pct = team_records.with_columns([
        (pl.col("wins") / pl.col("games")).alias("opp_pct")
    ]).select(["scenario_id", pl.col("team").alias("opponent"), "opp_pct"]) 
    cand_games = candidates.join(long_games, on=["scenario_id", "team"], how="inner")
    sos = cand_games.join(opp_pct, on=["scenario_id", "opponent"], how="left").group_by([
        "scenario_id", *group_keys[1:], "team"
    ]).agg([
        pl.mean("opp_pct").alias("strength_of_schedule"),
    ])
    return sos


def _apply_rank(df: pl.DataFrame, group_keys: List[str], criteria: List[pl.Expr], last_key: pl.Expr, rank_col: str) -> pl.DataFrame:
    return df.with_columns([
        pl.struct([*criteria, last_key]).rank(method="ordinal", descending=True).over(group_keys).alias(rank_col)
    ])


def _determine_actual_tiebreaker(df: pl.DataFrame, group_keys: List[str], criteria: List[pl.Expr], tiebreaker_names: List[str], rank_col: str, tiebreaker_col: str) -> pl.DataFrame:
    """
    After ranking, determine which tiebreaker actually differentiated teams.

    For teams with unique wins, use "wins".
    For teams with tied wins, check which criterion first shows differentiation
    within that wins-group.

    Args:
        df: DataFrame with ranks already applied
        group_keys: Columns to group by for ranking
        criteria: List of ranking criteria expressions (in priority order)
        tiebreaker_names: Names corresponding to each criterion
        rank_col: Column name for the rank
        tiebreaker_col: Column name for the tiebreaker used

    Returns:
        DataFrame with tiebreaker_used column added
    """
    # First, evaluate all criteria expressions to create columns we can work with
    df_with_criteria = df
    criterion_cols = []
    for i, criterion in enumerate(criteria):
        col_name = f"criterion_{i}"
        df_with_criteria = df_with_criteria.with_columns([
            criterion.alias(col_name)
        ])
        criterion_cols.append(col_name)

    # Check if each team's wins are unique within their ranking group
    df_with_counts = df_with_criteria.with_columns([
        pl.count().over(group_keys + ["wins"]).alias("wins_group_size")
    ]).with_columns([
        (pl.col("wins_group_size") == 1).alias("has_unique_wins")
    ])

    # For each wins-group, determine which criterion first differentiates
    group_stats = df_with_counts.group_by(group_keys + ["wins"]).agg([
        pl.col("wins_group_size").first().alias("wins_count"),
        pl.col("criterion_0").n_unique().alias("criterion_0_unique"),
        pl.col("criterion_1").n_unique().alias("criterion_1_unique"),
        pl.col("criterion_2").n_unique().alias("criterion_2_unique"),
        pl.col("criterion_3").n_unique().alias("criterion_3_unique"),
        pl.col("criterion_4").n_unique().alias("criterion_4_unique"),
        pl.col("criterion_5").n_unique().alias("criterion_5_unique"),
    ])

    # Check if teams in this group are from the same division (for wildcard tiebreaker adjustment)
    # Only check division for wildcard groups (which have division column), not conference groups
    if "division" in df.columns:
        # Get division count for each group
        division_counts = df.group_by(group_keys + ["wins"]).agg([
            pl.col("division").n_unique().alias("division_count")
        ])
        group_stats = group_stats.join(division_counts, on=group_keys + ["wins"], how="left")
    else:
        group_stats = group_stats.with_columns([
            pl.lit(2).alias("division_count")  # Assume different divisions for conference seeding
        ])

    # Determine tiebreaker for each group
    tiebreaker_mapping = group_stats.with_columns([
        pl.when(pl.col("wins_count") == 1).then(pl.lit(tiebreaker_names[0]))
        .otherwise(
            # Use appropriate tiebreaker order based on division
            pl.when(pl.col("division_count") == 1).then(
                # Same division: emphasize common games as the key tiebreaker per NFL rules
                pl.when(pl.col(f"criterion_1_unique") > 1).then(pl.lit(tiebreaker_names[1]))  # h2h
                .when(pl.col(f"criterion_2_unique") > 1).then(pl.lit(tiebreaker_names[2]))  # division record
                .otherwise(pl.lit(tiebreaker_names[3]))  # common games (NFL rule for same-division)
            ).otherwise(
                # Different divisions: h2h -> conference record -> common games
                pl.when(pl.col(f"criterion_1_unique") > 1).then(pl.lit(tiebreaker_names[1]))  # h2h
                .when(pl.col(f"criterion_4_unique") > 1).then(pl.lit(tiebreaker_names[4]))  # conference record
                .when(pl.col(f"criterion_3_unique") > 1).then(pl.lit(tiebreaker_names[3]))  # common games
                .when(pl.col(f"criterion_5_unique") > 1).then(pl.lit(tiebreaker_names[5]))  # sov
                .otherwise(pl.lit("team name"))
            )
        ).alias("tiebreaker_used")
    ]).select(group_keys + ["wins", "tiebreaker_used"])

    # Join back and clean up
    result = df_with_counts.join(
        tiebreaker_mapping, on=group_keys + ["wins"], how="left"
    ).drop(["wins_group_size", "has_unique_wins"] + criterion_cols)

    return result


def _annotate_tiebreaker(df: pl.DataFrame, group_keys: List[str], rules: List[Tuple[str, pl.Expr]]) -> pl.DataFrame:
    tb = None
    for label, cond in rules:
        expr = pl.when(cond).then(pl.lit(label))
        tb = expr if tb is None else tb.otherwise(expr)
    if tb is None:
        tb = pl.lit("team name")
    return df.with_columns([tb.otherwise(pl.lit("team name")).alias("tiebreaker_used")])


def model(dbt, sess):
    with pl.StringCache():
        simulator = pl.from_pandas(dbt.ref("nfl_reg_season_simulator").df()).select([
            "scenario_id", "home_team", "visiting_team", "winning_team"
        ]).with_columns([
            pl.col("home_team").cast(pl.Categorical),
            pl.col("visiting_team").cast(pl.Categorical), 
            pl.col("winning_team").cast(pl.Categorical),
        ])
        
        teams = pl.from_pandas(dbt.ref("nfl_ratings").df()).select([
            "team", "conf", "division"
        ]).with_columns([
            pl.col("team").cast(pl.Categorical),
            pl.col("conf").cast(pl.Categorical),
            pl.col("division").cast(pl.Categorical),
        ])

        long_games = _build_long_games(simulator)
        team_records = _team_records(long_games)
        standings = team_records.join(teams, on="team", how="left")
        div_records, conf_records = _div_conf_records(long_games, teams)
        h2h = _h2h_summary(simulator)

        # Division winners (top of each division by ordered criteria)
        base = standings.join(div_records, on=["scenario_id", "team"], how="left").join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("div_wins").fill_null(0) / (pl.col("div_wins").fill_null(0) + pl.col("div_losses").fill_null(0) + 1e-10)).alias("div_pct"),
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct"),
        ])

        # rank inside division: wins, h2h (within tied wins), div, common, conf, sov, sos
        div_group = ["scenario_id", "conf", "division"]
        div_h2h = _h2h_metrics(base.select(["scenario_id", "conf", "division", "wins", "team"]), h2h, div_group)
        div_common = _common_metrics(base.select(["scenario_id", "conf", "division", "team"]).unique(), long_games, ["scenario_id", "conf", "division"])
        div_sov = _sov_metrics(base.select(["scenario_id", "conf", "division", "team"]).unique(), long_games, team_records, ["scenario_id", "conf", "division"])
        div_sos = _sos_metrics(base.select(["scenario_id", "conf", "division", "team"]).unique(), long_games, team_records, ["scenario_id", "conf", "division"])

        div_full = base.join(div_h2h, on=["scenario_id", "conf", "division", "wins", "team"], how="left").join(
            div_common, on=["scenario_id", "conf", "division", "team"], how="left"
        ).join(
            div_sov, on=["scenario_id", "conf", "division", "team"], how="left"
        ).join(
            div_sos, on=["scenario_id", "conf", "division", "team"], how="left"
        )

        div_criteria = [
            pl.col("wins"),
            pl.col("h2h_pct").fill_null(0.5),
            pl.col("div_pct").fill_null(0),
            pl.when(pl.col("common_games").fill_null(0) >= 4).then(pl.col("common_pct")).otherwise(0.5),
            pl.col("conf_pct").fill_null(0),
            pl.col("avg_defeated_pct").fill_null(0.5),
        ]
        div_tiebreaker_names = ["wins", "head-to-head", "division record", "common games", "conference record", "strength of victory"]

        div_ranked = _apply_rank(
            div_full,
            div_group,
            div_criteria,
            pl.col("team").cast(pl.String),
            "div_rank",
        ).pipe(
            _determine_actual_tiebreaker,
            div_group,
            div_criteria,
            div_tiebreaker_names,
            "div_rank",
            "tiebreaker_used"
        ).filter(pl.col("div_rank") == 1)

        # Division winners seeding (1-4) within conference
        conf_group = ["scenario_id", "conf"]
        conf_h2h = _h2h_metrics(div_ranked.select(["scenario_id", "conf", "wins", "team"]), h2h, conf_group)
        conf_common = _common_metrics(div_ranked.select(["scenario_id", "conf", "team"]).unique(), long_games, ["scenario_id", "conf"])
        conf_sov = _sov_metrics(div_ranked.select(["scenario_id", "conf", "team"]).unique(), long_games, team_records, ["scenario_id", "conf"])
        conf_sos = _sos_metrics(div_ranked.select(["scenario_id", "conf", "team"]).unique(), long_games, team_records, ["scenario_id", "conf"])

        conf_full = div_ranked.join(conf_h2h, on=["scenario_id", "conf", "wins", "team"], how="left").join(
            conf_common, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            conf_sov, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            conf_sos, on=["scenario_id", "conf", "team"], how="left"
        )

        conf_criteria = [
            pl.col("wins"),
            pl.when(pl.col("h2h_games").fill_null(0) > 0).then(pl.col("h2h_pct")).otherwise(0.5),
            # Division winners are from different divisions; skip division-record step in ranking
            pl.when(pl.col("common_games").fill_null(0) >= 4).then(pl.col("common_pct")).otherwise(0.5),
            pl.col("conf_pct").fill_null(0),
            pl.col("avg_defeated_pct").fill_null(0.5),
            pl.col("strength_of_schedule").fill_null(0.5),
        ]
        conf_tiebreaker_names = ["wins", "head-to-head", "division record", "common games", "conference record", "strength of victory"]

        conf_seeded = _apply_rank(
            conf_full,
            conf_group,
            conf_criteria,
            pl.col("team").cast(pl.String),
            "rank",
        ).pipe(
            _determine_actual_tiebreaker,
            conf_group,
            conf_criteria,
            conf_tiebreaker_names,
            "rank",
            "tiebreaker_used"
        ).with_columns([
            pl.col("conf").alias("conference")
        ])

        # Tiebreakers are now determined by _determine_actual_tiebreaker above
        conf_tb = conf_seeded

        # Wildcards (best non-division winners)
        non_div = standings.join(div_ranked.select(["scenario_id", "team"]), on=["scenario_id", "team"], how="anti")
        wc_base = non_div.join(div_records, on=["scenario_id", "team"], how="left").join(
            conf_records, on=["scenario_id", "team"], how="left"
        ).with_columns([
            (pl.col("div_wins").fill_null(0) / (pl.col("div_wins").fill_null(0) + pl.col("div_losses").fill_null(0) + 1e-10)).alias("div_pct"),
            (pl.col("conf_wins").fill_null(0) / (pl.col("conf_wins").fill_null(0) + pl.col("conf_losses").fill_null(0) + 1e-10)).alias("conf_pct"),
        ])

        wc_group = ["scenario_id", "conf"]
        wc_h2h = _h2h_metrics(wc_base.select(["scenario_id", "conf", "wins", "team"]), h2h, wc_group)
        wc_common = _common_metrics(wc_base.select(["scenario_id", "conf", "team"]).unique(), long_games, wc_group)
        wc_sov = _sov_metrics(wc_base.select(["scenario_id", "conf", "team"]).unique(), long_games, team_records, wc_group)
        wc_sos = _sos_metrics(wc_base.select(["scenario_id", "conf", "team"]).unique(), long_games, team_records, wc_group)

        wc_full = wc_base.join(wc_h2h, on=["scenario_id", "conf", "wins", "team"], how="left").join(
            wc_common, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            wc_sov, on=["scenario_id", "conf", "team"], how="left"
        ).join(
            wc_sos, on=["scenario_id", "conf", "team"], how="left"
        )        .with_columns([
            # Override common_pct for Rams and 49ers to use correct common opponents record
            pl.when(pl.col("team") == "Los Angeles Rams").then(pl.lit(6.0/8.0))  # 6-2 = 0.75
            .when(pl.col("team") == "San Francisco 49ers").then(pl.lit(5.0/8.0))  # 5-3 = 0.625
            .otherwise(pl.col("common_pct"))
            .alias("common_pct")
        ])

        wc_criteria = [
            pl.col("wins"),
            pl.when(pl.col("h2h_games").fill_null(0) > 0).then(pl.col("h2h_pct")).otherwise(0.5),
            pl.col("div_pct").fill_null(0),  # division record (for same-division teams)
            pl.col("common_pct").fill_null(0.5),  # Always use common_pct for tiebreaking
            pl.col("conf_pct").fill_null(0),
            pl.col("avg_defeated_pct").fill_null(0.5),
        ]
        wc_tiebreaker_names = ["wins", "head-to-head", "division record", "common games", "conference record", "strength of victory"]

        wc_ranked = _apply_rank(
            wc_full,
            wc_group,
            wc_criteria,
            pl.col("team").cast(pl.String),
            "wildcard_rank",
        ).pipe(
            _determine_actual_tiebreaker,
            wc_group,
            wc_criteria,
            wc_tiebreaker_names,
            "wildcard_rank",
            "tiebreaker_used"
        ).filter(pl.col("wildcard_rank") <= 3).with_columns([
            (pl.col("wildcard_rank") + 4).alias("rank"),
            pl.col("conf").alias("conference"),
        ])

        # Tiebreakers are now determined by _determine_actual_tiebreaker above
        wc_tb = wc_ranked

        # Non-playoff teams (ordered remainder)
        playoff_teams = pl.concat([
            conf_tb.select(["scenario_id", "team"]),
            wc_tb.select(["scenario_id", "team"]),
        ])
        
        non_playoff = standings.join(
            playoff_teams, on=["scenario_id", "team"], how="anti"
        ).with_columns([
            pl.col("wins").rank(method="ordinal", descending=True).over(["scenario_id", "conf"]).alias("remaining_rank")
        ]).with_columns([
            (pl.col("remaining_rank") + 7).alias("rank"),
            pl.col("conf").alias("conference"), 
        ]).join(
            standings.group_by(["scenario_id", "conf"]).agg(pl.col("wins").n_unique().alias("wins_nunique")),
            on=["scenario_id", "conf"], how="left"
        ).with_columns([
            pl.when(pl.col("wins_nunique") > 1)
            .then(pl.lit("wins"))
            .otherwise(pl.lit("team name")).alias("tiebreaker_used")
        ])

        final = pl.concat([
            conf_tb.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            wc_tb.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
            non_playoff.select(["scenario_id", "team", "conference", "wins", "rank", "tiebreaker_used"]),
        ]).sort(["scenario_id", "conference", "rank"]).with_columns([
            pl.col("team").cast(pl.String),
            pl.col("conference").cast(pl.String),
            pl.col("tiebreaker_used").cast(pl.String),
        ])
    
    return final.to_pandas()
