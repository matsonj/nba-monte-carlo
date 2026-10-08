import os

import dlt
from dlt.sources.helpers import requests

# Season start year, e.g. 2026 for the 2026-27 season. ESPN's year/week params
# only resolve for the most recently published season and date ranges are
# rejected (400), so fetch both calendar years the season spans and keep only
# events tagged with this season.
season = int(os.environ.get("MDS_NFL_SEASON", "2026"))
events = {}
for year in (season, season + 1):
    response = requests.get(
        "https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
        f"?dates={year}&limit=1000",
        headers={
            "User-Agent": "nba-monte-carlo/1.0 (+https://github.com/matsonj/nba-monte-carlo)",
        },
    )
    response.raise_for_status()
    for event in response.json().get("events", []):
        if event["season"]["year"] == season:
            events[event["id"]] = event

# ESPN postseason week numbers -> continuation of regular season numbering,
# matching how downstream models identify playoff rounds (wk >= 19).
# Week 4 (Pro Bowl) is intentionally absent.
POSTSEASON_WEEKS = {1: 19, 2: 20, 3: 21, 5: 22}


def games():
    for event in events.values():
        season_type = event["season"]["type"]
        week = event["week"]["number"]
        if season_type == 2:
            pass  # regular season: use week as-is
        elif season_type == 3 and week in POSTSEASON_WEEKS:
            week = POSTSEASON_WEEKS[week]
        else:
            continue  # preseason, Pro Bowl, etc.

        competition = event["competitions"][0]
        completed = competition["status"]["type"]["completed"]
        home = next(c for c in competition["competitors"] if c["homeAway"] == "home")
        away = next(c for c in competition["competitors"] if c["homeAway"] == "away")
        home_pts = int(home["score"]) if completed else None
        away_pts = int(away["score"]) if completed else None

        # mirror the Pro-Football-Reference convention the models were built on:
        # one row per game with winner/loser columns; ties list the home team
        # first and are detected downstream via equal scores
        if completed and away_pts > home_pts:
            winner, winner_pts, loser, loser_pts = away["team"]["displayName"], away_pts, home["team"]["displayName"], home_pts
        else:
            winner, winner_pts, loser, loser_pts = home["team"]["displayName"], home_pts, away["team"]["displayName"], away_pts

        yield {
            "event_id": event["id"],
            "date": event["date"],
            "week": week,
            "season_type": season_type,
            "completed": completed,
            "neutral_site": 1 if competition.get("neutralSite") else 0,
            "home_team": home["team"]["displayName"],
            "away_team": away["team"]["displayName"],
            "winner": winner,
            "winner_pts": winner_pts,
            "loser": loser,
            "loser_pts": loser_pts,
        }


pipeline = dlt.pipeline(
    pipeline_name="nfl_pipeline",
    destination=dlt.destinations.filesystem(bucket_url="data/nfl"),
    dataset_name="nfl_data",
)
# Explicit column types so score columns exist in the output schema even at
# season start, when no game is completed and every score is null.
load_info = pipeline.run(
    games(),
    table_name="games",
    write_disposition="replace",
    loader_file_format="csv",
    columns={
        "winner_pts": {"data_type": "bigint"},
        "loser_pts": {"data_type": "bigint"},
    },
)

print(load_info)
