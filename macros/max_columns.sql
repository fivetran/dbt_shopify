{# 
    Returns the maximum number of columns that can be added via metafields based on
    the source table's column count and additional columns joined or added downstream
#}
{%- macro max_columns(source_table_column_count, id_column) -%}
    {{ return(adapter.dispatch('max_columns', 'shopify')(source_table_column_count, id_column)) }} 
{%- endmacro -%}

{%- macro default__max_columns(source_table_column_count, id_column) -%}
{# Snowflake #}
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


{# 
    Determines how many columns are added downstream for each object 
    If we explicitly add any fields to the following end models (not in the staging layer), we need to update the
    counts here to ensure we don't exceed the column limits of the data warehouse.
#}
{%- macro downstream_model_column_count(id_column) -%}
    {{ return(adapter.dispatch('downstream_model_column_count', 'shopify')(id_column)) }} 
{%- endmacro -%}

{%- macro default__downstream_model_column_count(id_column) -%}
    {%- if var('shopify_api', 'rest') == 'rest' -%}

        {%- if id_column == 'customer_id' %}
            {# shopify__customers and shopify__customer_emails #}
            {{ return(19 + (1 if var('shopify_using_abandoned_checkout', True) else 0)) }}

        {%- elif id_column == 'order_id' -%}
            {# shopify__orders #}
            {{ return(20) }}

        {%- elif id_column == 'product_id' -%}
            {# shopify__products #}
            {{ return(11) }}

        {%- elif id_column == 'variant_id' -%}
            {# shopify__inventory_levels #}
            {%- set inventory_states = var('shopify_inventory_states', ['incoming', 'on_hand', 'available', 'committed', 'reserved', 'damaged', 'safety_stock', 'quality_control']) -%}
            {{ return(84 + inventory_states | length + (1 if var('shopify_using_product_variant_media', False) else 0) )}}

        {%- elif id_column == 'shop_id' %}
            {# shopify__daily_shop #}
            {{ return(36 + (3 if var('shopify_using_abandoned_checkout', True) else 0) + (11 if var('shopify_using_fulfillment_event', false) else 0)) }}

        {%- else -%}
            {# collection - not joined anywhere downstream #}
            {{ return(0) }}
        {%- endif -%}

    {%- else -%}

        {%- if id_column == 'customer_id' %}
            {# shopify_gql__customers and shopify_gql__customer_emails #}
            {{ return(19 + (1 if var('shopify_gql_using_abandoned_checkout', True) else 0)) }}

        {%- elif id_column == 'order_id' -%}
            {# shopify_gql__orders #}
            {{ return(22) }}

        {%- elif id_column == 'product_id' -%}
            {# shopify_gql__products #}
            {{ return(11) }}

        {%- elif id_column == 'variant_id' -%}
            {# shopify_gql__inventory_levels #}
            {%- set inventory_states = var('shopify_inventory_states', ['incoming', 'on_hand', 'available', 'committed', 'reserved', 'damaged', 'safety_stock', 'quality_control']) -%}
            {{ return(77 + inventory_states | length + (1 if var('shopify_gql_using_product_variant_media', False) else 0) )}}

        {%- elif id_column == 'shop_id' %}
            {# shopify_gql__daily_shop #}
            {{ return(36 + (3 if var('shopify_gql_using_abandoned_checkout', True) else 0) + (10 if var('shopify_gql_using_fulfillment_event', false) else 0)) }}

        {%- else -%}
            {# collection - not joined anywhere downstream #}
            {{ return(0) }}
        {%- endif -%}

    {%- endif -%}
{%- endmacro -%}