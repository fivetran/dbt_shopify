{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with products as (

    select *
    from {{ ref('int_shopify_gql__products_with_aggregates') }}

), product_order_lines as (

    select *
    from {{ ref('int_shopify_gql__product_order_line_aggregates')}}

{# {% set product_metafields_enabled = var('shopify_gql_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_product_metafields', True)) %}
{% if product_metafields_enabled %}

), product_metafields as (

    select *
    from {{ ref('shopify_gql__product_metafields') }}

{% endif %} #}

), joined as (

    select
        products.*, -- contains product and collection metafields

        {# {% if product_metafields_enabled -%} 
            {%- set product_metafield_columns = adapter.get_columns_in_relation(ref('shopify__product_metafields')) -%}

            {%- for column in product_metafield_columns -%}
                {% if column.name.startswith('metafield_') %}
        , product_metafields.{{ column.name }}
                {% endif %}
            {%- endfor %}
        {% endif %} #}

        coalesce(product_order_lines.quantity_sold,0) as total_quantity_sold,
        coalesce(product_order_lines.subtotal_sold,0) as subtotal_sold,
        coalesce(product_order_lines.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        coalesce(product_order_lines.subtotal_sold_net_refunds,0) as subtotal_sold_net_refunds,
        product_order_lines.first_order_timestamp,
        product_order_lines.most_recent_order_timestamp,
        product_order_lines.avg_quantity_per_order_line as avg_quantity_per_order_line,
        coalesce(product_order_lines.product_total_discount,0) as product_total_discount,
        product_order_lines.product_avg_discount_per_order_line as product_avg_discount_per_order_line,
        coalesce(product_order_lines.product_total_tax,0) as product_total_tax,
        product_order_lines.product_avg_tax_per_order_line as product_avg_tax_per_order_line

    from products
    left join product_order_lines
        on products.product_id = product_order_lines.product_id
        and products.source_relation = product_order_lines.source_relation

    {# {% if product_metafields_enabled %}
    left join product_metafields 
        on shop_calendar.source_relation = product_metafields.source_relation
        and shop_calendar.shop_id = product_metafields.product_id
    {% endif %} #}
)

select *
from joined