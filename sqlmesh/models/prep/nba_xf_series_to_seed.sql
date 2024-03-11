MODEL (
  name nba.xf_series_to_seed,
  kind VIEW
);

SELECT
    series_id,
    seed
FROM nba.raw_xf_series_to_seed;
