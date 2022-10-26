{{
    config(
        materialized = "view" if target.name == 'parquet' else "table",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/data_catalog/conformed/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
            if target.name == 'parquet' else " "
) }}

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM {{ ref( 'scenario_gen' ) }} AS i
CROSS JOIN {{ ref( 'schedules' ) }} AS S
