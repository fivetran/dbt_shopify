{% macro get_discount_application_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "allocation_method", "datatype": dbt.type_string()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "target_selection", "datatype": dbt.type_string()},
    {"name": "target_type", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_float()},
    {"name": "value_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_discount_application_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "allocation_method", "datatype": dbt.type_string()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "target_selection", "datatype": dbt.type_string()},
    {"name": "target_type", "datatype": dbt.type_string()},
    {"name": "value_amount", "datatype": dbt.type_float()},
    {"name": "value_currency_code", "datatype": dbt.type_string()},
    {"name": "value_percentage", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}