with customers as (

    select *
    from {{ var('shopify_customer') }}

), orders as (

    select *
    from {{ ref('shopify__customers__order_aggregates' )}}

), joined as (

    select 
        customers.*,
        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        orders.average_order_value,
        coalesce(orders.number_of_orders, 0) as number_of_orders,
        coalesce(orders.lifetime_total_price, 0) as lifetime_total_price
    from customers
    left join orders
        using (customer_id)

)

select *
from joined