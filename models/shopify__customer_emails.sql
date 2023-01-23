with customer_emails as (

    select 
        {{ dbt_utils.star(from=ref('int_shopify__customer_email_rollup'), except=["orders_count", "total_spent"]) }}
    from {{ ref('int_shopify__customer_email_rollup') }}

), orders as (

    select *
    from {{ ref('int_shopify__emails__order_aggregates' )}}

), joined as (

    select 
        customer_emails.*,
        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        coalesce(orders.average_order_value, 0) as average_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_amount,
        coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders,

        --new columns************************
        coalesce(orders.average_quantity_per_order, 0) as average_quantity_per_order,
        coalesce(orders.lifetime_total_discount, 0) as lifetime_total_discount,
        coalesce(orders.lifetime_total_shipping, 0) as lifetime_total_shipping,
        coalesce(orders.lifetime_total_shipping_with_discounts, 0) as lifetime_total_shipping_with_discounts,
        coalesce(orders.lifetime_total_shipping_tax, 0) as lifetime_total_shipping_tax

    from customer_emails
    left join orders
        on customer_emails.email = orders.email
        and customer_emails.source_relation = orders.source_relation

)

select *
from joined