{%- macro does_table_exist(table_name, source_name) -%}
    {{ return(adapter.dispatch('does_table_exist', 'shopify')(table_name, source_name)) }}
{% endmacro %}

{% macro default__does_table_exist(table_name, source_name) %}
    {%- if execute -%}
    {%- set source_relation = adapter.get_relation(
        database=source(source_name, table_name).database,
        schema=source(source_name, table_name).schema,
        identifier=source(source_name, table_name).name) -%}

    {% set table_exists=source_relation is not none %}
    {{ return(table_exists) }}
    {%- endif -%} 

{% endmacro %}