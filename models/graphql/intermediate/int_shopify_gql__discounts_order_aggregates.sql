{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_discount_code as (

    select *
    from {{ ref('int_shopify_gql__order_discount_code') }}
),

orders as (

    select *
    from {{ ref('shopify_gql__orders') }}
),

orders_aggregated as (

    select 
        order_discount_code.code,
        order_discount_code.type,
        order_discount_code.source_relation,
        avg(order_discount_code.value_amount) as avg_order_discount_amount,
        sum(coalesce(order_discount_code.value_amount, 0)) as total_order_discount_amount,
        max(orders.total_line_items_price_shop_amount) as total_order_line_items_price, -- summing would multiply the total by the # of discount codes applied to an order
        max(orders.shipping_cost_shop_amount) as total_order_shipping_cost, -- summing would multiply the total by the # of discount codes applied to an order
        max(orders.refund_subtotal + orders.refund_total_tax) as total_order_refund_amount, -- summing would multiply the total by the # of discount codes applied to an order
        count(distinct customer_id) as count_customers,
        count(distinct email) as count_customer_emails,
        count(distinct order_discount_code.order_id) as count_orders

    from order_discount_code
    join orders 
        on order_discount_code.order_id = orders.order_id 
        and order_discount_code.source_relation = orders.source_relation

    group by 1,2,3
)

select *
from orders_aggregated