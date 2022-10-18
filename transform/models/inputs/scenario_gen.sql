{% if target.name == 'parquet' %}
{{
  config(
    materialized = "ephemeral"
) }}
{% elif target.name != 'parquet' %}
{{
  config(
    materialized = "view"
) }}
{% endif %}

SELECT I.generate_series AS scenario_id
FROM generate_series(1, 1000) AS I
