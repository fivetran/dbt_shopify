{%- macro json_to_string(column, column_list) -%}
    {{ return(adapter.dispatch('json_to_string', 'shopify')(column, column_list)) }}
{%- endmacro -%}

{%- macro default__json_to_string(column, column_list) -%}
    {{ column }}
{%- endmacro -%}

{%- macro bigquery__json_to_string(column, column_list) -%}
    {%- set columns = column_list -%}
    {%- set ns = namespace(column_type='string') -%}

    {%- for col in columns -%}
        {%- if col.name|lower == column|lower -%}
            {%- set ns.column_type = col.dtype|lower -%}
        {%- endif -%}
    {%- endfor -%}

    {%- if ns.column_type == 'json' -%}
        to_json_string({{ column }})
    {%- else -%}
        {{ column }}
    {%- endif -%}
{%- endmacro -%}
