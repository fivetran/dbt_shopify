with customers as (

    select 
        {# {{ dbt_utils.star(from=ref('stg_shopify__customer'), except=["orders_count", "total_spent"]) }} #}
        {{ dbt_utils.star(from=ref('stg_shopify__customer'), except=["total_spent"]) }}
    from {{ var('shopify_customer') }}

), orders as (

    select *
    from {{ ref('shopify__customers__order_aggregates' )}}

), abandoned as (

    select 
        customer_id,
        source_relation,
        count(customer_id) as lifetime_abandoned_checkouts
    from {{ var('shopify_abandoned_checkout' )}}
    where customer_id is not null
    group by 1,2

), joined as (

    select 
        customers.*,
        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        coalesce(orders.average_order_value, 0) as average_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_amount,
        
        -- start new column
        {# coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders, #}
        coalesce(orders.average_quantity_per_order, 0) as average_quantity_per_order,
        orders.customer_tags, 
        coalesce(abandoned.lifetime_abandoned_checkouts, 0) as lifetime_abandoned_checkouts,
        coalesce(orders.lifetime_total_tax, 0) as lifetime_total_tax,
        coalesce(orders.average_tax_per_order, 0) as average_tax_per_order,
        coalesce(orders.lifetime_total_shipping, 0) as lifetime_total_shipping,
        coalesce(orders.average_shipping_per_order, 0) as average_shipping_per_order,
        coalesce(orders.lifetime_total_shipping_with_discounts, 0) as lifetime_total_shipping_with_discounts,
        coalesce(orders.average_shipping_with_discounts_per_order, 0) as average_shipping_with_discounts_per_order,
        coalesce(orders.lifetime_total_shipping_tax, 0) as lifetime_total_shipping_tax,
        coalesce(orders.average_shipping_tax_per_order, 0) as average_shipping_tax_per_order,
        coalesce(orders.lifetime_total_discount, 0) as lifetime_total_discount,
        coalesce(orders.average_discount_per_order, 0) as average_discount_per_order

    from customers
    left join orders
        using (customer_id, source_relation)
    left join abandoned
        on customers.customer_id = abandoned.customer_id
        and customers.source_relation = abandoned.source_relation
)

select *
from joined