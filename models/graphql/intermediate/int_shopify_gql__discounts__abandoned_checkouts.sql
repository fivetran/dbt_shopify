{{ config(enabled=(var('shopify_using_abandoned_checkout', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with abandoned_checkout as (

    select *
    from {{ ref('int_shopify_gql__abandoned_checkout') }}

    -- "deleted" abandoned checkouts do not appear to have any data tying them to customers,
    -- discounts, or products (and should therefore not get joined in) but let's filter them out here
    where not coalesce(is_deleted, false)
),

discount_application as (

    select *
    from {{ var('shopify_gql_discount_application') }}
),

abandoned_checkout_discount_code as (

    select *
    from {{ var('shopify_gql_abandoned_checkout_discount_code') }}

    -- we need the TYPE of discount (shipping, percentage, fixed_amount) to avoid fanning out of joins
    -- so filter out records that have this
    where coalesce(type, '') != ''
),

join_abandoned_checkout_discount_code as (

    select 
        abandoned_checkout_discount_code.checkout_id,
        abandoned_checkout_discount_code.source_relation,
        abandoned_checkout_discount_code.code,
        abandoned_checkout_discount_code.index,
        discount_application.value_type as type

    from abandoned_checkout_discount_code
    left join discount_application
        on abandoned_checkout_discount_code.checkout_id = discount_application.checkout_id
        and abandoned_checkout_discount_code.source_relation = discount_application.source_relation
        -- and abandoned_checkout_discount_code.index = discount_application.index
        {# NEED CODE #}
    where coalesce(discount_application.value_type, '') != ''
)

{# TABLE HAS BEEN REMOVED

abandoned_checkout_shipping_line as (

    select *
    from {{ var('shopify_abandoned_checkout_shipping_line') }}
),

roll_up_shipping_line as (

    select 
        checkout_id,
        source_relation,
        sum(price) as price

    from abandoned_checkout_shipping_line
    group by 1,2
),
#}
abandoned_checkouts_aggregated as (

    select 
        abandoned_checkout_discount_code.code,
        abandoned_checkout_discount_code.type,
        abandoned_checkout_discount_code.source_relation,
        sum(coalesce(abandoned_checkout.total_discounts_set_shop_amount), 0) as total_abandoned_checkout_discount_amount,
        sum(coalesce(abandoned_checkout.total_line_items_price_set_shop_amount, 0)) as total_abandoned_checkout_line_items_price,
        {# sum(coalesce(roll_up_shipping_line.price, 0)) as total_abandoned_checkout_shipping_price, #}
        count(distinct abandoned_checkout.customer_id) as count_abandoned_checkout_customers,
        count(distinct abandoned_checkout.email) as count_abandoned_checkout_customer_emails,
        count(distinct abandoned_checkout.checkout_id) as count_abandoned_checkouts

    from abandoned_checkout_discount_code
    left join abandoned_checkout
        on abandoned_checkout_discount_code.checkout_id = abandoned_checkout.checkout_id
        and abandoned_checkout_discount_code.source_relation = abandoned_checkout.source_relation
    {# left join roll_up_shipping_line
        on roll_up_shipping_line.checkout_id = abandoned_checkout_discount_code.checkout_id 
        and roll_up_shipping_line.source_relation = abandoned_checkout_discount_code.source_relation #}

    group by 1,2,3
)

select *
from abandoned_checkouts_aggregated