{% macro get_graphql_return_columns() %}

{% set columns = [
    {"name": "_fivetran_synced",    "datatype": dbt.type_timestamp()},
    {"name": "decline_note",        "datatype": dbt.type_string()},
    {"name": "decline_reason",      "datatype": dbt.type_string()},
    {"name": "id",                  "datatype": dbt.type_int()},
    {"name": "name",                "datatype": dbt.type_string()},
    {"name": "order_id",            "datatype": dbt.type_int()},
    {"name": "status",              "datatype": dbt.type_string()},
    {"name": "total_quantity",      "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_return_line_item_columns() %}

{% set columns = [
    {"name": "_fivetran_synced",        "datatype": dbt.type_timestamp()},
    {"name": "customer_note",           "datatype": dbt.type_string()},
    {"name": "id",                      "datatype": dbt.type_int()},
    {"name": "order_line_id",           "datatype": dbt.type_int()},
    {"name": "quantity",                "datatype": dbt.type_int()},
    {"name": "refundable_quantity",     "datatype": dbt.type_int()},
    {"name": "refunded_quantity",       "datatype": dbt.type_int()},
    {"name": "return_id",               "datatype": dbt.type_int()},
    {"name": "return_reason",           "datatype": dbt.type_string()},
    {"name": "return_reason_note",      "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_return_shipping_fee_columns() %}

{% set columns = [
    {"name": "_fivetran_synced",                            "datatype": dbt.type_timestamp()},
    {"name": "amount_set_presentment_money_amount",         "datatype": dbt.type_float()},
    {"name": "amount_set_presentment_money_currency_code",  "datatype": dbt.type_string()},
    {"name": "amount_set_shop_money_amount",                "datatype": dbt.type_float()},
    {"name": "amount_set_shop_money_currency_code",         "datatype": dbt.type_string()},
    {"name": "id",                                          "datatype": dbt.type_int()},
    {"name": "return_id",                                   "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
