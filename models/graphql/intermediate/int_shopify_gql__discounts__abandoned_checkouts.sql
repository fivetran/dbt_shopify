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
),

{# WIP #}
join_abandoned_checkout_discount_code as (

    select 
        abandoned_checkout_discount_code.checkout_id,
        abandoned_checkout_discount_code.source_relation,
        abandoned_checkout_discount_code.code,
        abandoned_checkout_discount_code.index,
        discount_application.value_type as type

    from abandoned_checkout_discount_code
    left join discount_application
        on abandoned_checkout_discount_code.code = discount_application.code
        and abandoned_checkout_discount_code.source_relation = discount_application.source_relation
        -- and abandoned_checkout_discount_code.index = discount_application.index
        {# NEED CODE to prevent potential fanout #}
    where coalesce(discount_application.value_type, '') != ''
),

{#
abandoned_checkout_shipping_line TABLE HAS BEEN REMOVED
#}

abandoned_checkouts_aggregated as (

    select 
        join_abandoned_checkout_discount_code.code,
        join_abandoned_checkout_discount_code.type,
        join_abandoned_checkout_discount_code.source_relation,
        sum(coalesce(abandoned_checkout.total_discount_shop_amount, 0)) as total_abandoned_checkout_discount_amount,
        sum(coalesce(abandoned_checkout.total_line_items_price_shop_amount, 0)) as total_abandoned_checkout_line_items_price,
        {# sum(coalesce(roll_up_shipping_line.price, 0)) as total_abandoned_checkout_shipping_price, #}
        count(distinct abandoned_checkout.customer_id) as count_abandoned_checkout_customers,
        count(distinct abandoned_checkout.email) as count_abandoned_checkout_customer_emails,
        count(distinct abandoned_checkout.checkout_id) as count_abandoned_checkouts

    from join_abandoned_checkout_discount_code
    left join abandoned_checkout
        on join_abandoned_checkout_discount_code.checkout_id = abandoned_checkout.checkout_id
        and join_abandoned_checkout_discount_code.source_relation = abandoned_checkout.source_relation

    group by 1,2,3
)

select *
from abandoned_checkouts_aggregated