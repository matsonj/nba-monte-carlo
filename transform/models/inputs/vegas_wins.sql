{% if target.name == 'parquet' %}
{{
  config(
    materialized = "ephemeral"
) }}
{% endif %}

{% if target.name != 'parquet' %}
{{
  config(
    materialized = "view"
) }}
{% endif %}

SELECT
    team,
    win_total
{% if target.name == 'parquet' %}
FROM '/tmp/storage/raw_team_ratings/*.parquet'
{% elif target.name != 'parquet' %}
FROM {{ source( 'nba', 'raw_team_ratings' ) }}
{% endif %}
GROUP BY ALL
