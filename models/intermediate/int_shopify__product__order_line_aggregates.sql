with order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders')}}

), product_order_aggregated as (
    select 
        orders.order_id,
        orders.source_relation,
        order_lines.product_id,
        sum(order_lines.quantity) as order_product_quanity,
        sum(order_lines.total_discount) as order_product_discount,
        sum(order_lines.order_line_tax) as order_product_tax 
    
    from orders
    left join order_lines
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation

    group by 1,2,3

), product_aggregated as (
    select 
        order_lines.product_id,
        order_lines.source_relation,

        -- moved over from shopify__products
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.pre_tax_price) as subtotal_sold,
        sum(order_lines.quantity_net_refunds) as quantity_sold_net_refunds,
        sum(order_lines.subtotal_net_refunds) as subtotal_sold_net_refunds,
        {# min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp, #}
        null as first_order_timestamp,
        null as most_recent_order_timestamp,

        -- new columns
        sum(order_lines.total_discount) as product_total_discount,
        sum(order_lines.order_line_tax) as product_total_tax,
        avg(product_order_aggregated.order_product_quanity) as average_quantity_per_order,
        avg(product_order_aggregated.order_product_discount) as product_average_discount_per_order,
        avg(product_order_aggregated.order_product_tax) as product_average_tax_per_order

    from order_lines
    {# left join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation #}
    left join product_order_aggregated
        on order_lines.product_id = product_order_aggregated.product_id
        and order_lines.source_relation = product_order_aggregated.source_relation

    group by 1,2

)

select *
from product_aggregated