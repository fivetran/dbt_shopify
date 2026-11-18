{% macro get_graphql_fulfillment_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "discounted_total_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "discounted_total_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "discounted_total_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "discounted_total_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "fulfillment_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "original_total_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "original_total_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "original_total_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "original_total_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "product_id", "datatype": dbt.type_int()},
    {"name": "product_variant_id", "datatype": dbt.type_int()},
    {"name": "quantity", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
