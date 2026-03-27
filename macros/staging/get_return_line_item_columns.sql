{% macro get_graphql_return_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "customer_note", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "refundable_quantity", "datatype": dbt.type_int()},
    {"name": "refunded_quantity", "datatype": dbt.type_int()},
    {"name": "return_id", "datatype": dbt.type_int()},
    {"name": "return_reason_note", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
