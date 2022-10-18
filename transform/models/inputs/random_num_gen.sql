{% if target.name == 'parquet' %}
{{
    config(
        materialized = "view",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}
{% endif %}

{% if target.name != 'parquet' %}
{{
    config(
        materialized = "table"
) }}
{% endif %}

SELECT
    i.scenario_id,
    S.game_id,
    (random() * 10000)::smallint AS rand_result
FROM {{ ref( 'scenario_gen' ) }} AS i
CROSS JOIN {{ ref( 'schedules' ) }} AS S
