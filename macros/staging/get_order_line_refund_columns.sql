{% macro get_order_line_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_numeric()},
    {"name": "location_id", "datatype": dbt.type_numeric()},
    {"name": "order_line_id", "datatype": dbt.type_numeric()},
    {"name": "subtotal", "datatype": dbt.type_numeric()},
    {"name": "subtotal_set", "datatype": dbt.type_string()},
    {"name": "total_tax", "datatype": dbt.type_numeric()},
    {"name": "total_tax_set", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_float()},
    {"name": "refund_id", "datatype": dbt.type_numeric()},
    {"name": "restock_type", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('order_line_refund_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_order_line_refund_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "location_id", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "quantity", "datatype": dbt.type_float()},
    {"name": "refund_id", "datatype": dbt.type_int()},
    {"name": "restock_type", "datatype": dbt.type_string()},
    {"name": "subtotal_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "subtotal_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "subtotal_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "subtotal_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "total_tax_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "total_tax_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "total_tax_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "total_tax_set_shop_currency_code", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('order_line_refund_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}