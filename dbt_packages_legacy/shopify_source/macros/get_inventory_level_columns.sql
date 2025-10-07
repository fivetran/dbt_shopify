{% macro get_inventory_level_columns() %}

{# Columns below line 13 to be deprecated. #}
{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "inventory_item_id", "datatype": dbt.type_int()},
    {"name": "location_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "can_deactivate", "datatype": dbt.type_boolean()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "deactivation_alert", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()}
    ,
    {"name": "available", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
