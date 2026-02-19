{% macro get_return_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "return_id", "datatype": dbt.type_numeric()},
    {"name": "fulfillment_line_item_id", "datatype": dbt.type_numeric()},
    {"name": "quantity", "datatype": dbt.type_float()},
    {"name": "refundable_quantity", "datatype": dbt.type_float()},
    {"name": "refunded_quantity", "datatype": dbt.type_float()},
    {"name": "return_reason", "datatype": dbt.type_string()},
    {"name": "return_reason_note", "datatype": dbt.type_string()},
    {"name": "restock_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
