{% macro get_graphql_return_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "decline_note", "datatype": dbt.type_string()},
    {"name": "decline_reason", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "total_quantity", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
