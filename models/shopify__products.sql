with products as (

    select *
    from {{ var('shopify_product') }}

), order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders')}}

), order_lines_aggregated as (

    select 
        order_lines.product_id, 
        order_lines.source_relation,
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.pre_tax_price) as subtotal_sold,

        {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
        sum(order_lines.quantity_net_refunds) as quantity_sold_net_refunds,
        sum(order_lines.subtotal_net_refunds) as subtotal_sold_net_refunds,
        {% endif %}

        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp
    from order_lines
    left join orders
        using (order_id, source_relation)
    group by 1,2

), joined as (

    select
        products.*,
        coalesce(order_lines_aggregated.quantity_sold,0) as quantity_sold,
        coalesce(order_lines_aggregated.subtotal_sold,0) as subtotal_sold,

        {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
        coalesce(order_lines_aggregated.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        coalesce(order_lines_aggregated.subtotal_sold_net_refunds,0) as subtotal_sold_net_refunds,
        {% endif %}
        
        order_lines_aggregated.first_order_timestamp,
        order_lines_aggregated.most_recent_order_timestamp
    from products
    left join order_lines_aggregated
        using (product_id, source_relation)

)

select *
from joined