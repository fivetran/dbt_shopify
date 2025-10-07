with orders as (

    select *
    from {{ ref('stg_salla__order') }}
    where customer_id is not null

), order_aggregates as (

    select *
    from {{ ref('int_salla__order__line_aggregates') }}

), transactions as (

    select *
    from {{ ref('stg_salla__transaction')}}

    where lower(transaction_status) = 'success'

), transaction_aggregates as (
    -- this is necessary as customers can pay via multiple payment gateways
    select
        order_id,
        source_relation,
        lower(transaction_type) as transaction_type,
        sum(amount) as amount

    from transactions
    group by 1, 2, 3

), aggregated as (

    select
        orders.customer_id,
        orders.source_relation,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,
        avg(transaction_aggregates.amount) as avg_order_value,
        sum(case when transaction_aggregates.transaction_type in ('sale','capture','payment') then transaction_aggregates.amount else 0 end) as lifetime_total_spent,
        sum(case when transaction_aggregates.transaction_type = 'refund' then transaction_aggregates.amount else 0 end) as lifetime_total_refunded,
        count(distinct orders.order_id) as lifetime_count_orders,
        avg(order_aggregates.order_total_quantity) as avg_quantity_per_order

    from orders
    left join transaction_aggregates
        on orders.order_id = transaction_aggregates.order_id
        and orders.source_relation = transaction_aggregates.source_relation
    left join order_aggregates
        on orders.order_id = order_aggregates.order_id
        and orders.source_relation = order_aggregates.source_relation

    group by 1, 2

)

select *
from aggregated
