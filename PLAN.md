# BS Pod Over/Unders

## Status

Canonical CSV, dbt model/tests, Evidence queries, the NFC summary page, sidebar ordering, and conditional pick formatting are implemented. The full pipeline and Evidence production build pass. Local preview is running on `feature/bs-pod-over-unders`.

## Goal

Show what Bill Simmons and Cousin Sal picked for each NFC team's regular-season win total, then track those picks live and settle them after the regular season.

## Scope decisions

- Cover the current 2026 NFC season only.
- Use a one-time, manually reviewed transcript extraction.
- Keep one canonical Bill pick and one canonical Sal pick per team.
- Retain episode date and transcript or episode URL for provenance.
- Require manual review for ambiguous or conflicting transcript statements; never guess.
- Compare picks against regular-season wins.
- Show live status as `On track` or `Behind`.
- Count only settled picks in Bill and Sal's aggregate records. Track open picks and pushes separately.
- Keep the picks in one place on the current-season, NFC-only `BS Pod Over/Unders` summary page.

## Canonical CSV

Proposed path: `data/nfl/bs_pod_over_unders.csv`

Required columns:

```text
season,speaker,team,pick,line,episode_date,episode_url
```

Field rules:

- `season`: integer season start year, currently `2026`.
- `speaker`: `Bill Simmons` or `Cousin Sal`.
- `team`: exact long team name used by the existing NFL ratings source.
- `pick`: `over` or `under`.
- `line`: numeric win-total line, preserving decimal values.
- `line` is the common market line for the segment; alternate lines mentioned in discussion are not canonical.
- `episode_date`: ISO date.
- `episode_url`: canonical source URL.
- Exactly one row per `(season, speaker, team)` after review.
- No transcript quote is required in the app; provenance is episode/date/link only.

## Status and settlement logic

- Required wins for an over are strictly greater than the line.
- Required wins for an under are strictly less than the line.
- Final equality is a push.
- Before the season ends, `On track` means current completed wins are already on the selected side of the line; otherwise show `Behind`. A pick remains open until the regular season is complete.
- Aggregate speaker records count only settled wins, losses, and pushes; open picks are displayed separately.

## Implementation outline

1. Use the supplied current-season NFC transcript and manually extract both speakers' explicit win-total picks.
2. Review ambiguous rows and normalize every team to the existing NFL team names.
3. Add the reviewed CSV as a DuckDB/dbt source under `data/nfl`.
4. Add a dbt model that validates the canonical rows, joins current regular-season wins, and computes live and final statuses.
5. Add Evidence queries for the summary scoreboard, projected wins, and pick statuses.
6. Add `evidence/pages/nfl/bs-pod-over-unders.md` for the current-season scoreboard.
7. Set the NFL sidebar order and conditionally format the Bill and Sal pick cells.
8. Verify CSV cardinality, dbt models, full pipeline, and Evidence production build.

## Acceptance criteria

- All 16 NFC teams have one reviewed Bill row and one reviewed Sal row, for exactly 32 rows.
- Every row has a valid `over`/`under` pick, numeric line, canonical team, episode date, and source URL.
- The summary page shows both picks, lines, projected wins, live status, and provenance link.
- The summary page shows Bill and Sal settled wins, losses, pushes, open picks, and all team rows.
- Live statuses update from the existing regular-season results data.
- Final equal-to-line outcomes are represented as pushes.
- The existing NBA/NFL pipeline and Evidence build continue to complete successfully.

## Explicit non-goals

- Automated transcript fetching or parsing.
- Historical seasons.
- ROI or betting-profit calculations.
- Verbatim transcript quotes in the UI.
