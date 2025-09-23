{% macro get_graphql_customer_visit_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "landing_page", "datatype": dbt.type_string()},
    {"name": "landing_page_html", "datatype": dbt.type_string()},
    {"name": "occurred_at", "datatype": dbt.type_timestamp()},
    {"name": "referral_code", "datatype": dbt.type_string()},
    {"name": "referral_info_html", "datatype": dbt.type_string()},
    {"name": "referrer_url", "datatype": dbt.type_string()},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "source_description", "datatype": dbt.type_string()},
    {"name": "source_type", "datatype": dbt.type_string()},
    {"name": "utm_parameters_campaign", "datatype": dbt.type_string()},
    {"name": "utm_parameters_content", "datatype": dbt.type_string()},
    {"name": "utm_parameters_medium", "datatype": dbt.type_string()},
    {"name": "utm_parameters_source", "datatype": dbt.type_string()},
    {"name": "utm_parameters_term", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}