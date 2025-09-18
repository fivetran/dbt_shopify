{% macro get_graphql_fulfillment_order_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "fulfillment_order_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "image_alt_text", "datatype": dbt.type_string()},
    {"name": "image_height", "datatype": dbt.type_int()},
    {"name": "image_id", "datatype": dbt.type_int()},
    {"name": "image_url", "datatype": dbt.type_string()},
    {"name": "image_width", "datatype": dbt.type_int()},
    {"name": "inventory_item_id", "datatype": dbt.type_int()},
    {"name": "order_line_item_id", "datatype": dbt.type_int()},
    {"name": "product_title", "datatype": dbt.type_string()},
    {"name": "product_variant_id", "datatype": dbt.type_int()},
    {"name": "remaining_quantity", "datatype": dbt.type_int()},
    {"name": "requires_shipping", "datatype": dbt.type_boolean()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "total_quantity", "datatype": dbt.type_int()},
    {"name": "variant_title", "datatype": dbt.type_string()},
    {"name": "vendor", "datatype": dbt.type_string()},
    {"name": "weight_unit", "datatype": dbt.type_string()},
    {"name": "weight_value", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
