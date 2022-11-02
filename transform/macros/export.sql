{% macro export_to_parquet(enable_export_var) %}

{% set relations_to_export = dbt_utils.get_relations_by_pattern(
    schema_pattern='%export',
    table_pattern='%%'
) %}

{{ log('Statements to run:', info=True) }}

{% for relation in relations_to_export %}
    {% set export_command -%}
        COPY (SELECT * FROM {{ relation }} ) TO '/tmp/data_catalog/conformed/{{ relation.name }}.parquet' (FORMAT 'parquet', CODEC 'ZSTD');
    {%- endset %}
    {% do log(export_command, info=True) %}
    {% if enable_export_var == true %}
        {% do run_query(export_command) %}
    {% endif %}
    {% set export_command = true %}
{% endfor %}

{% do run_query(sql_to_execute) %}
{% endmacro %}
