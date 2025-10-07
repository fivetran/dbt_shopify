with customers as (

    select *
    from {{ ref('stg_salla__customer') }}

), orders as (

    select *
    from {{ ref('salla__customers__order_aggregates' )}}

), abandoned as (

    select
        customer_id,
        source_relation,
        count(distinct abandoned_cart_id) as lifetime_abandoned_checkouts
    from {{ ref('stg_salla__abandoned_cart') }}
    where customer_id is not null
    group by 1, 2

), joined as (

    select
        customers.*,

        coalesce(abandoned.lifetime_abandoned_checkouts, 0) as lifetime_abandoned_checkouts,

        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        orders.avg_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_net,
        coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders,
        orders.avg_quantity_per_order

    from customers
    left join orders
        on customers.customer_id = orders.customer_id
        and customers.source_relation = orders.source_relation
    left join abandoned
        on customers.customer_id = abandoned.customer_id
        and customers.source_relation = abandoned.source_relation

)

select *
from joined
