{% macro get_product_media_columns() %}

{% set columns = [
    {"name": "product_id", "datatype": dbt.type_bigint()},
    {"name": "media_id", "datatype": dbt.type_bigint()}
] %}

{{ return(columns) }}

{% endmacro %}
