-- depends-on: {{ ref( 'reg_season_end' ) }}

{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO 's3://datalake/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

WITH cte_teams AS (
    SELECT
        scenario_id,
        conf,
        winning_team,
        seed,
        elo_rating
    FROM {{ "'s3://datalake/conformed/reg_season_end.parquet'" if target.name == 'parquet'
        else ref( 'reg_season_end' ) }}
    WHERE season_rank < 7
    UNION ALL
    SELECT *
    FROM {{ ref('playin_sim_r2_end' ) }}
)

SELECT T.*
FROM cte_teams T
