{% macro get_graphql_collection_rule_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "collection_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "condition", "datatype": dbt.type_string()},
    {"name": "relation", "datatype": dbt.type_string()},
    {"name": "columns", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}