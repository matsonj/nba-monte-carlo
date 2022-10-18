-- depends-on: {{ ref( 'reg_season_end' ) }}

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

WITH cte_teams AS (
    SELECT
        scenario_id,
        conf,
        winning_team,
        seed,
        elo_rating
    {% if target.name == 'parquet' %}
    FROM '/tmp/storage/reg_season_end.parquet'
    {% elif target.name != 'parquet' %}
    FROM {{ ref( 'reg_season_end' ) }}
    {% endif %}
    WHERE season_rank < 7
    UNION ALL
    SELECT *
    FROM {{ ref('playin_sim_r2_end' ) }}
)

SELECT T.*
FROM cte_teams T
