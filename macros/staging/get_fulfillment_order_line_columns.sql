{% macro get_fulfillment_order_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "fulfillable_quantity", "datatype": dbt.type_int()},
    {"name": "fulfillment_id", "datatype": dbt.type_int()},
    {"name": "fulfillment_service", "datatype": dbt.type_string()},
    {"name": "gift_card", "datatype": dbt.type_boolean()},
    {"name": "grams", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "product_id", "datatype": dbt.type_int()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "requires_shipping", "datatype": dbt.type_boolean()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "taxable", "datatype": dbt.type_boolean()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "variant_id", "datatype": dbt.type_int()},
    {"name": "variant_title", "datatype": dbt.type_string()},
    {"name": "vendor", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
