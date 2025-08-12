{% macro get_product_variant_media_columns() %}

{% set columns = [
    {"name": "product_variant_id", "datatype": dbt.type_bigint()},
    {"name": "media_id", "datatype": dbt.type_bigint()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_product_variant_media_columns() %}

{% set columns = [
    {"name": "product_variant_id", "datatype": dbt.type_bigint()},
    {"name": "media_id", "datatype": dbt.type_bigint()}
] %}

{{ return(columns) }}

{% endmacro %}