{%- macro max_columns(source_table_column_count) -%}
    {{ return(adapter.dispatch('max_columns', 'shopify')(source_table_column_count)) }} 
{%- endmacro -%}

{%- macro default__max_columns(source_table_column_count) -%}
{{ return(none) }}
{%- endmacro -%}

{%- macro bigquery__max_columns(source_table_column_count) -%}
{{ return(10000 - source_table_column_count) }}
{%- endmacro -%}

{%- macro postgres__max_columns(source_table_column_count) -%}
{{ return(1600 - source_table_column_count) }}
{%- endmacro -%}

{%- macro spark__max_columns(source_table_column_count) -%}
{{ return(32768 - source_table_column_count) }}
{%- endmacro -%}