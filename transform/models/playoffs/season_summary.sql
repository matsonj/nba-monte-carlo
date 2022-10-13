-- depends-on: {{ ref( 'reg_season_summary' ) }}

{{
  config(
    materialized = "view",
    post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}

SELECT R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
FROM '/tmp/storage/reg_season_summary.parquet' R
LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team