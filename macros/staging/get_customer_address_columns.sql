{% macro get_graphql_customer_address_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "address_1", "datatype": dbt.type_string()},
    {"name": "address_2", "datatype": dbt.type_string()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "country_code", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "is_default", "datatype": dbt.type_boolean()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "latitude", "datatype": dbt.type_string()},
    {"name": "longitude", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "province", "datatype": dbt.type_string()},
    {"name": "province_code", "datatype": dbt.type_string()},
    {"name": "zip", "datatype": dbt.type_string()},
    {"name": "validation_result_summary", "datatype": dbt.type_string()},
    {"name": "timezone", "datatype": dbt.type_string()},
    {"name": "coordinates_validated", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}