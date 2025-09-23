{% macro get_tax_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "price_set", "datatype": dbt.type_string()},
    {"name": "rate", "datatype": dbt.type_float()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_tax_line_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "order_line_id", "datatype": dbt.type_int()},
    {"name": "price_set_pres_amount", "datatype": dbt.type_float()},
    {"name": "price_set_pres_currency_code", "datatype": dbt.type_string()},
    {"name": "price_set_shop_amount", "datatype": dbt.type_float()},
    {"name": "price_set_shop_currency_code", "datatype": dbt.type_string()},
    {"name": "rate", "datatype": dbt.type_float()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
