{% macro get_inventory_item_columns() %}

{# Columns below line 26 to be deprecated. #}
{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "country_code_of_origin", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_bigint()},
    {"name": "province_code_of_origin", "datatype": dbt.type_string()},
    {"name": "requires_shipping", "datatype": dbt.type_boolean()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "tracked", "datatype": dbt.type_boolean()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "duplicate_sku_count", "datatype": dbt.type_int()},
    {"name": "harmonized_system_code", "datatype": dbt.type_string()},
    {"name": "inventory_history_url", "datatype": dbt.type_string()},
    {"name": "legacy_resource_id", "datatype": dbt.type_bigint()},
    {"name": "measurement_id", "datatype": dbt.type_bigint()},
    {"name": "measurement_weight_value", "datatype": dbt.type_float()},
    {"name": "measurement_weight_unit", "datatype": dbt.type_string()},
    {"name": "tracked_editable_locked", "datatype": dbt.type_boolean()},
    {"name": "tracked_editable_reason", "datatype": dbt.type_string()},
    {"name": "unit_cost_amount", "datatype": dbt.type_float()},
    {"name": "unit_cost_currency_code", "datatype": dbt.type_string()}
    ,
    {"name": "cost", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}


{% macro get_graphql_inventory_item_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "country_code_of_origin", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "duplicate_sku_count", "datatype": dbt.type_int()},
    {"name": "harmonized_system_code", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "inventory_history_url", "datatype": dbt.type_string()},
    {"name": "legacy_resource_id", "datatype": dbt.type_int()},
    {"name": "measurement_id", "datatype": dbt.type_int()},
    {"name": "measurement_weight_unit", "datatype": dbt.type_string()},
    {"name": "measurement_weight_value", "datatype": dbt.type_float()},
    {"name": "province_code_of_origin", "datatype": dbt.type_string()},
    {"name": "requires_shipping", "datatype": dbt.type_boolean()},
    {"name": "sku", "datatype": dbt.type_string()},
    {"name": "tracked", "datatype": dbt.type_boolean()},
    {"name": "tracked_editable_locked", "datatype": dbt.type_boolean()},
    {"name": "tracked_editable_reason", "datatype": dbt.type_string()},
    {"name": "unit_cost_amount", "datatype": dbt.type_float()},
    {"name": "unit_cost_currency_code", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
