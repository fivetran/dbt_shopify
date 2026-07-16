{#
    DuckDB-compatible override for fivetran_utils.json_parse.
    DuckDB uses json_extract_string with a JSONPath string rather than variadic key arguments.
#}
{% macro duckdb__json_parse(string, string_path) %}
  json_extract_string({{string}}, '${%- for s in string_path -%}{% if s is number %}[{{ s }}]{% else %}.{{ s }}{% endif %}{%- endfor -%}')
{% endmacro %}
