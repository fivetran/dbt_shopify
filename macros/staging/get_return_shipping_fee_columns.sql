{% macro get_graphql_return_shipping_fee_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount_set_presentment_money_amount", "datatype": dbt.type_float()},
    {"name": "amount_set_presentment_money_currency_code", "datatype": dbt.type_string()},
    {"name": "amount_set_shop_money_amount", "datatype": dbt.type_float()},
    {"name": "amount_set_shop_money_currency_code", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "return_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}