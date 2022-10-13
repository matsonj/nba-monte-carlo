-- depends-on: {{ ref( 'reg_season_end' ) }}

{{
  config(
    materialized = "table",
    post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}

WITH cte_teams AS (
    SELECT
        scenario_id,
        conf,
        winning_team,
        seed,
        elo_rating
    FROM '/tmp/storage/reg_season_end.parquet'
    WHERE season_rank < 7
    UNION ALL
    SELECT *
    FROM {{ ref('playin_sim_r2_end' ) }}
)

SELECT T.*
FROM cte_teams T