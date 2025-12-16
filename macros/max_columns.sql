{# Return the maximum number of columns that can be added via metafields #}
{%- macro max_columns(source_table_column_count, id_column) -%}
    {{ return(adapter.dispatch('max_columns', 'shopify')(source_table_column_count, id_column)) }} 
{%- endmacro -%}

{%- macro default__max_columns(source_table_column_count, id_column) -%}
{{ return(none) }}
{%- endmacro -%}

{%- macro bigquery__max_columns(source_table_column_count, id_column) -%}
{{ return(10000 - source_table_column_count - downstream_model_column_count(id_column)) }}
{%- endmacro -%}

{%- macro postgres__max_columns(source_table_column_count, id_column) -%}
{{ return(1600 - source_table_column_count - downstream_model_column_count(id_column)) }}
{%- endmacro -%}

{%- macro spark__max_columns(source_table_column_count, id_column) -%}
{{ return(32768 - source_table_column_count - downstream_model_column_count(id_column)) }}
{%- endmacro -%}


{# Determine how many columns are added downstream #}
{%- macro downstream_model_column_count(id_column) -%}
    {{ return(adapter.dispatch('downstream_model_column_count', 'shopify')(id_column)) }} 
{%- endmacro -%}

{%- macro default__downstream_model_column_count(id_column) -%}
    {%- if var('shopify_api', 'rest') == 'rest' -%}

        {%- if id_column == 'cutomer_id' %}
            {# Taking max between shopify__customers and shopify__customer_emails #}
            {{ return(19 + (1 if var('shopify_using_abandoned_checkout', True) else 0)) }}

        {%- elif id_column == 'order_id' -%}
            {{ return(20) }}

        {%- elif id_column == 'product_id' -%}
            {{ return(11) }}

        {%- elif id_column == 'variant_id' -%}
            {%- set inventory_states = var('shopify_inventory_states', ['incoming', 'on_hand', 'available', 'committed', 'reserved', 'damaged', 'safety_stock', 'quality_control']) -%}
            {{ return(84 + inventory_states | length + (1 if var('shopify_using_product_variant_media', False) else 0) )}}

        {%- elif id_column == 'shop_id' %}
            {{ return(36 + (3 if var('shopify_using_abandoned_checkout', True) else 0) + (11 if var('shopify_using_fulfillment_event', false) else 0)) }}

        {%- else -%}
            {# collection #}
            {{ return(0) }}
        {%- endif -%}

    {%- else -%}

        {%- if id_column == 'cutomer_id' %}
            {# Taking max between shopify__customers and shopify__customer_emails #}
            {{ return(19 + (1 if var('shopify_gql_using_abandoned_checkout', True) else 0)) }}

        {%- elif id_column == 'order_id' -%}
            {{ return(22) }}

        {%- elif id_column == 'product_id' -%}
            {{ return(11) }}

        {%- elif id_column == 'variant_id' -%}
            {%- set inventory_states = var('shopify_inventory_states', ['incoming', 'on_hand', 'available', 'committed', 'reserved', 'damaged', 'safety_stock', 'quality_control']) -%}
            {{ return(77 + inventory_states | length + (1 if var('shopify_gql_using_product_variant_media', False) else 0) )}}

        {%- elif id_column == 'shop_id' %}
            {{ return(36 + (3 if var('shopify_gql_using_abandoned_checkout', True) else 0) + (10 if var('shopify_gql_using_fulfillment_event', false) else 0)) }}

        {%- else -%}
            {# collection #}
            {{ return(0) }}
        {%- endif -%}

    {%- endif -%}
{%- endmacro -%}