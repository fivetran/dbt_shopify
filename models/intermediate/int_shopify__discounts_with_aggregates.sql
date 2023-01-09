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
    from {{ var('shopify_orders') }}
),

abandoned_checkout_aggregated as (

    select 
        upper(abandoned_checkout_discount_code.discount_code) as discount_code,
        sum(coalesce(abandoned_checkout.total_line_items_price, 0)) as total_line_items_price,
        sum(coalesce(abandoned_checkout.price, 0)) as total_shipping_price 

    from abandoned_checkout_discount_code
    left join abandoned_checkout
        on abandoned_checkout_discount_code.checkout_id = abandoned_checkout.checkout_id
        and abandoned_checkout_discount_code.source_relation = abandoned_checkout.source_relation
    left join abandoned_checkout_shipping_line
        on abandoned_checkout_shipping_line.checkout_id = abandoned_checkout_discount_code.checkout_id 
        and abandoned_checkout_shipping_line.source_relation = abandoned_checkout_discount_code.source_relation

    group by 1
)

select *
from abandoned_checkout_aggregated