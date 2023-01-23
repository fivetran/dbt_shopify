with orders as (

    select *
    from {{ var('shopify_order') }}
    where email is not null

), transactions as (

    select *
    from {{ ref('shopify__transactions' )}}
    where lower(status) = 'success'

), order_line as (

    select
        *
    from {{ ref('shopify__orders__order_line_aggregates')}}

), aggregated as (

    select
        orders.email,
        orders.source_relation,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,
        avg(case when lower(transactions.kind) in ('sale','capture') then transactions.currency_exchange_calculated_amount end) as average_order_value,
        sum(case when lower(transactions.kind) in ('sale','capture') then transactions.currency_exchange_calculated_amount end) as lifetime_total_spent,
        sum(case when lower(transactions.kind) in ('refund') then transactions.currency_exchange_calculated_amount end) as lifetime_total_refunded,
        count(distinct orders.order_id) as lifetime_count_orders,

        --new columns************************
        avg(order_line.order_total_quantity) as average_quantity_per_order,
        sum(order_line.order_total_discount) as lifetime_total_discount,
        sum(order_line.order_total_shipping) as lifetime_total_shipping,
        sum(order_line.order_total_shipping_with_discounts) as lifetime_total_shipping_with_discounts,
        sum(order_line.order_total_shipping_tax) as lifetime_total_shipping_tax

    from orders
    left join transactions
        on orders.order_id = transactions.order_id 
        and orders.source_relation = transactions.source_relation
    left join order_line
        on orders.order_id = order_line.order_id
        and orders.source_relation = order_line.source_relation

    group by 1,2

)

select *
from aggregated