{% if target.name == 'parquet' %}
{{
    config(
        materialized = "view",
        post_hook = "COPY (SELECT * FROM {{ this }} ) TO '/tmp/storage/{{ this.table }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');"
) }}
{% elif target.name != 'parquet' %}
{{
    config(
        materialized = "table"
) }}
{% endif %}

-- depends-on: {{ ref( 'playoff_sim_r1' ) }}

WITH cte_playoff_sim AS (
    {% if target.name == 'parquet' %}
    {{ playoff_sim('playoffs_r2','/tmp/storage/playoff_sim_r1.parquet') }}
    {% elif target.name != 'parquet' %}
    {{ playoff_sim('playoffs_r2','playoff_sim_r1' ) }}
    {% endif %}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}