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

-- depends-on: {{ ref( 'initialize_seeding' ) }}

WITH cte_playoff_sim AS (
    {% if target.name == 'parquet' %}
    {{ playoff_sim('playoffs_r1','/tmp/storage/initialize_seeding.parquet') }}
    {% elif target.name != 'parquet' %}
    {{ playoff_sim('playoffs_r1','initialize_seeding' ) }}
    {% endif %}
)

{{ playoff_sim_end( 'cte_playoff_sim' ) }}