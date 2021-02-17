with orders as (

    select *
    from {{ var('shopify_order') }}

), aggregated as (

    select
        customer_id,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as most_recent_order_timestamp,
        count(*) as number_of_orders,
        sum(total_price) as lifetime_total_price,
        avg(total_price)  as average_order_value
    from orders
    group by 1

)

select *
from aggregated