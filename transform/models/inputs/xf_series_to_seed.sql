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
    series_id,
    seed
{% if target.name == 'parquet' %}
FROM '/tmp/storage/raw_xf_series_to_seed/*.parquet'
{% elif target.name != 'parquet' %}
FROM {{ source('nba', 'raw_xf_series_to_seed' ) }}
{% endif %}
