with discount_code as (

    select * 
    from {{ var('shopify_discount_code') }}
),

abandoned_checkout as (

    select *
    from {{ var('shopify_abandoned_checkout') }}

    -- "deleted" abandoned checkouts do not appear to have any data tying them to customers,
    -- discounts, or products (and should therefore not get joined in) but let's filter them out here
    where not coalesce(is_deleted, false)
),

abandoned_checkout_discount_code as (

    select *
    from {{ var('shopify_abandoned_checkout_discount_code') }}
),

abandoned_checkout_shipping_line as (

    select *
    from {{ var('shopify_abandoned_checkout_shipping_line') }}
),

order_discount_code as (

    select *
    from {{ var('shopify_order_discount_code') }}
),

orders as (

    select *
    from {{ ref('shopify__orders') }}
),

abandoned_checkouts_aggregated as (

    select 
        abandoned_checkout_discount_code.discount_code,
        abandoned_checkout_discount_code.source_relation,
        sum(abandoned_checkout_discount_code.amount) as total_abandoned_checkout_discount_amount,
        sum(coalesce(abandoned_checkout.total_line_items_price, 0)) as total_abandoned_checkout_line_items_price,
        sum(coalesce(abandoned_checkout.price, 0)) as total_abandoned_checkout_shipping_price 

    from abandoned_checkout_discount_code
    left join abandoned_checkout
        on abandoned_checkout_discount_code.checkout_id = abandoned_checkout.checkout_id
        and abandoned_checkout_discount_code.source_relation = abandoned_checkout.source_relation
    left join abandoned_checkout_shipping_line
        on abandoned_checkout_shipping_line.checkout_id = abandoned_checkout_discount_code.checkout_id 
        and abandoned_checkout_shipping_line.source_relation = abandoned_checkout_discount_code.source_relation

    group by 1,2
),

orders_aggregated as (

    select 
        order_discount_code.code,
        order_discount_code.source_relation,
        sum(order_discount_code.amount) as total_order_discount_amount,
        sum(orders.refund_subtotal + orders.refund_total_tax) as total_order_refund_amount,
        sum(orders.order_adjusted_total) as total_order_amount_adjusted,
        sum(orders.total_price) as total_order_amount,
        sum(orders.shipping_cost) as total_order_shipping_cost

    from order_discount_code
    join orders 
        on order_discount_code.order_id = orders.order_id 
        and order_discount_code.source_relation = orders.source_relation

    group by 1,2
),

joined as (

    select 
        discount_code.*,
        coalesce(orders_aggregated.total_order_discount_amount, 0) as total_order_discount_amount
        coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_discount_amount, 0) as total_abandoned_checkout_discount_amount,
        coalesce(orders_aggregated.total_order_line_items_price, 0) as total_order_line_items_price,
        coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_line_items_price, 0) as total_abandoned_checkout_line_items_price,
        coalesce(orders_aggregated.total_order_shipping_cost, 0) as total_order_shipping_cost,
        coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_shipping_price, 0) as total_abandoned_checkout_shipping_price,
        coalesce(orders_aggregated.total_order_refund_amount, 0) as total_order_refund_amount

    from discount_code
    left join orders_aggregated
        on discount_code.code = orders_aggregated.code
        and discount_code.source_relation = orders_aggregated.source_relation
    left join abandoned_checkouts_aggregated
        on discount_code.code = abandoned_checkouts_aggregated.code
        and discount_code.source_relation = abandoned_checkouts_aggregated.source_relation
)

select *
from joined