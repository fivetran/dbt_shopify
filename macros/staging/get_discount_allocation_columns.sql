{% macro get_discount_allocation_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "amount_set_presentment_money_amount", "datatype": dbt.type_float()},
    {"name": "amount_set_presentment_money_currency_code", "datatype": dbt.type_string()},
    {"name": "amount_set_shop_money_amount", "datatype": dbt.type_float()},
    {"name": "amount_set_shop_money_currency_code", "datatype": dbt.type_string()},
    {"name": "discount_application_index", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_discount_allocation_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "allocated_amount_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "allocated_amount_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "allocated_amount_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "allocated_amount_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "discount_application_index", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
