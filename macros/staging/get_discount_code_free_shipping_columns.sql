{% macro get_discount_code_free_shipping_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "starts_at", "datatype": dbt.type_timestamp()},
    {"name": "ends_at", "datatype": dbt.type_timestamp()},
    {"name": "recurring_cycle_limit", "datatype": dbt.type_int()},
    {"name": "applies_once_per_customer", "datatype": dbt.type_boolean()},
    {"name": "async_usage_count", "datatype": dbt.type_int()},
    {"name": "usage_limit", "datatype": dbt.type_int()},
    {"name": "codes_count", "datatype": dbt.type_int()},
    {"name": "codes_precision", "datatype": dbt.type_string()},
    {"name": "combines_with_order_discounts", "datatype": dbt.type_boolean()},
    {"name": "combines_with_product_discounts", "datatype": dbt.type_boolean()},
    {"name": "combines_with_shipping_discounts", "datatype": dbt.type_boolean()},
    {"name": "customer_selection_all_customers", "datatype": dbt.type_boolean()},
    {"name": "total_sales_amount", "datatype": dbt.type_float()},
    {"name": "total_sales_currency_code", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_discount_code_free_shipping_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "starts_at", "datatype": dbt.type_timestamp()},
    {"name": "ends_at", "datatype": dbt.type_timestamp()},
    {"name": "recurring_cycle_limit", "datatype": dbt.type_int()},
    {"name": "applies_once_per_customer", "datatype": dbt.type_boolean()},
    {"name": "async_usage_count", "datatype": dbt.type_int()},
    {"name": "usage_limit", "datatype": dbt.type_int()},
    {"name": "codes_count", "datatype": dbt.type_int()},
    {"name": "codes_precision", "datatype": dbt.type_string()},
    {"name": "combines_with_order_discounts", "datatype": dbt.type_boolean()},
    {"name": "combines_with_product_discounts", "datatype": dbt.type_boolean()},
    {"name": "combines_with_shipping_discounts", "datatype": dbt.type_boolean()},
    {"name": "customer_selection_all_customers", "datatype": dbt.type_boolean()},
    {"name": "total_sales_amount", "datatype": dbt.type_float()},
    {"name": "total_sales_currency_code", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
