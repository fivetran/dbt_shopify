with products as (

    select *
    from {{ ref('stg_shopify__product') }}

), order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders')}}

), order_lines_aggregated as (

    select 
        order_lines.product_id, 
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.quantity_net_refunds) as quantity_sold_net_refunds,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp
    from order_lines
    left join orders
        using (order_id)
    group by 1

), joined as (

    select
        products.*,
        coalesce(order_lines_aggregated.quantity_sold,0) as quantity_sold,
        coalesce(order_lines_aggregated.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        order_lines_aggregated.first_order_timestamp,
        order_lines_aggregated.most_recent_order_timestamp
    from products
    left join order_lines_aggregated
        using (product_id)

)

select *
from joined