{% macro get_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_numeric()},
    {"name": "processed_at", "datatype": dbt.type_timestamp()},
    {"name": "restock", "datatype": dbt.type_boolean()},
    {"name": "total_duties_set", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_numeric()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "return_id", "datatype": dbt.type_int()},
    {"name": "staff_member_id", "datatype": dbt.type_int()},
    {"name": "total_refunded_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "total_refunded_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "total_refunded_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "total_refunded_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}