{% macro get_discount_redeem_code_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "async_usage_count", "datatype": dbt.type_int()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "created_by_description", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_int()},
    {"name": "created_by_title", "datatype": dbt.type_string()},
    {"name": "discount_id", "datatype": dbt.type_int()},
    {"name": "discount_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_discount_redeem_code_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "async_usage_count", "datatype": dbt.type_int()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "created_by_description", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_int()},
    {"name": "created_by_title", "datatype": dbt.type_string()},
    {"name": "discount_id", "datatype": dbt.type_int()},
    {"name": "discount_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}