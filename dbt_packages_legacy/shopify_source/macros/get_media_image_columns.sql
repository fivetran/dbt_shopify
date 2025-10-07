{% macro get_media_image_columns() %}

{% set columns = [
    {"name": "media_id", "datatype": dbt.type_bigint()},
    {"name": "image_id", "datatype": dbt.type_bigint()},
    {"name": "image_alt_text", "datatype": dbt.type_string()},
    {"name": "image_height", "datatype": dbt.type_int()},
    {"name": "image_url", "datatype": dbt.type_string()},
    {"name": "image_width", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}