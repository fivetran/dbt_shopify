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
        orders.average_order_value
    from customers
    left join orders
        using (customer_id)

)

select *
from joined