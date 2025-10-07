{% macro get_inventory_quantity_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "inventory_item_id", "datatype": dbt.type_int()},
    {"name": "inventory_level_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "quantity", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}