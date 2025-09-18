{% macro get_graphql_fulfillment_tracking_info_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "fulfillment_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "number", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
