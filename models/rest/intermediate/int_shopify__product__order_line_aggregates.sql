{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders')}}

), discount_allocations as (

    select *
    from {{ ref('stg_shopify__discount_allocation') }}

), discount_allocation_agg as (

    select
        order_line_id,
        source_relation,
        sum(amount) as discount_allocation_amount

    from discount_allocations
    group by 1, 2

), product_aggregated as (
    select
        order_lines.product_id,
        order_lines.source_relation,

        -- moved over from shopify__products
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.pre_tax_price) as subtotal_sold,
        sum(order_lines.quantity_net_refunds) as quantity_sold_net_refunds,
        sum(order_lines.subtotal_net_refunds) as subtotal_sold_net_refunds,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,

        sum(coalesce(discount_allocation_agg.discount_allocation_amount, 0)) as product_total_discount,
        sum(order_lines.order_line_tax) as product_total_tax,
        avg(order_lines.quantity) as avg_quantity_per_order_line,
        avg(coalesce(discount_allocation_agg.discount_allocation_amount, 0)) as product_avg_discount_per_order_line,
        avg(order_lines.order_line_tax) as product_avg_tax_per_order_line

    from order_lines
    left join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation
    left join discount_allocation_agg
        on order_lines.order_line_id = discount_allocation_agg.order_line_id
        and order_lines.source_relation = discount_allocation_agg.source_relation
    group by 1,2

)

select *
from product_aggregated