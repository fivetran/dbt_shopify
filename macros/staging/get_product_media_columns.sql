{% macro get_product_media_columns() %}

{% set columns = [
    {"name": "product_id", "datatype": dbt.type_bigint()},
    {"name": "media_id", "datatype": dbt.type_bigint()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_product_media_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "media_id", "datatype": dbt.type_int()},
    {"name": "product_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}