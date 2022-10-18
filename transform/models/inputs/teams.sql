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
    S.visitorneutral AS team_long,
    R.team
{% if target.name == 'parquet' %}
FROM '/tmp/storage/raw_schedule/*.parquet' AS S
{% elif target.name != 'parquet' %}
FROM {{ source( 'nba', 'raw_schedule' ) }} AS S
{% endif %}
    LEFT JOIN {{ ref( 'ratings' ) }} R ON R.team_long = S.visitorneutral
GROUP BY ALL
