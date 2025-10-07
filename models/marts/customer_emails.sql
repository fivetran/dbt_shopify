with customer_emails as (

    select * from {{ ref('int_shopify__customer_email_rollup') }}

), orders as (

    select
        lower(email) as email,
        source_relation,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as most_recent_order_timestamp,
        avg(total_price) as avg_order_value,
        sum(total_price) as lifetime_total_spent,
        sum(refund_subtotal) as lifetime_total_refunded,
        count(distinct order_id) as lifetime_count_orders,
        avg(line_item_count) as avg_quantity_per_order,
        sum(total_tax) as lifetime_total_tax,
        avg(total_tax) as avg_tax_per_order,
        sum(total_discounts) as lifetime_total_discount,
        avg(total_discounts) as avg_discount_per_order,
        sum(shipping_cost) as lifetime_total_shipping,
        avg(shipping_cost) as avg_shipping_per_order,
        sum(shipping_cost - shipping_discount_amount) as lifetime_total_shipping_with_discounts,
        avg(shipping_cost - shipping_discount_amount) as avg_shipping_with_discounts_per_order,
        sum(order_total_shipping_tax) as lifetime_total_shipping_tax,
        avg(order_total_shipping_tax) as avg_shipping_tax_per_order

    from {{ ref('orders') }}
    where email is not null
    group by 1, 2

), abandoned as (

    select
        lower(email) as email,
        'airbyte' as source_relation,
        count(distinct id) as lifetime_abandoned_checkouts

    from {{ source('shopify_raw', 'abandoned_checkouts') }}
    where email is not null
    group by 1, 2

), joined as (

    select
        customer_emails.*,

        coalesce(abandoned.lifetime_abandoned_checkouts, 0) as lifetime_abandoned_checkouts,

        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        orders.avg_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_net,
        coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders,
        orders.avg_quantity_per_order,
        coalesce(orders.lifetime_total_tax, 0) as lifetime_total_tax,
        orders.avg_tax_per_order,
        coalesce(orders.lifetime_total_discount, 0) as lifetime_total_discount,
        orders.avg_discount_per_order,
        coalesce(orders.lifetime_total_shipping, 0) as lifetime_total_shipping,
        orders.avg_shipping_per_order,
        coalesce(orders.lifetime_total_shipping_with_discounts, 0) as lifetime_total_shipping_with_discounts,
        orders.avg_shipping_with_discounts_per_order,
        coalesce(orders.lifetime_total_shipping_tax, 0) as lifetime_total_shipping_tax,
        orders.avg_shipping_tax_per_order

    from customer_emails
    left join orders
        on customer_emails.email = orders.email
        and customer_emails.source_relation = orders.source_relation
    left join abandoned
        on customer_emails.email = abandoned.email
        and customer_emails.source_relation = abandoned.source_relation

)

select *
from joined
