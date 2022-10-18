-- depends-on: {{ ref( 'reg_season_summary' ) }}

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

SELECT R.*,
    P.made_playoffs,
    P.made_conf_semis,
    P.made_conf_finals,
    P.made_finals,
    P.won_finals
{% if target.name == 'parquet' %}
FROM '/tmp/storage/reg_season_summary.parquet' R
{% elif target.name != 'parquet' %}
FROM {{ ref( 'reg_season_summary' ) }} R
{% endif %}
LEFT JOIN {{ ref( 'playoff_summary' ) }} P ON P.team = R.team
