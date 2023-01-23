with order_line as (

    select *
    from {{ var('shopify_order_line') }}

), order_shipping_line as (

    select
        *
    from {{ var('shopify_order_shipping_line')}}

), order_shipping_tax_line as (

    select
        *
    from {{ var('shopify_order_shipping_tax_line')}} 



), aggregated as (

    select 
        order_line.order_id,
        order_line.source_relation,
        count(*) as line_item_count,
        -- start new columns QUESTION: do I need to consider currency for the below?
        sum(order_line.quantity) as order_total_quantity,
        sum(order_line.total_discount) as order_total_discount,
        sum(order_shipping_line.price) as order_total_shipping,
        sum(order_shipping_line.discounted_price) as order_total_shipping_with_discounts,
        sum(order_shipping_tax_line.price) as order_total_shipping_tax

    from order_line
    left join order_shipping_line
        on order_line.order_id = order_shipping_line.order_id
        and order_line.source_relation = order_shipping_line.source_relation
    left join order_shipping_tax_line
        on order_shipping_line.order_shipping_line_id = order_shipping_tax_line.order_shipping_line_id
        and order_shipping_line.source_relation = order_shipping_tax_line.source_relation
    group by 1,2

)

select *
from aggregated