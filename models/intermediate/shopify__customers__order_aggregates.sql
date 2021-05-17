with orders as (

    select *
    from {{ var('shopify_order') }}

), transactions as (

    select *
    from {{ ref('shopify__transactions' )}}

), transaction_refund_adjustment as (

    select
        *,
        case when lower(kind) = 'refund'
            then currency_exchange_calculated_amount * -1
            else currency_exchange_calculated_amount
                end as adjusted_amount
    from transactions
    where lower(status) = 'success'

), aggregated as (

    select
        orders.customer_id,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,
        avg(case when lower(transaction_refund_adjustment.kind) in ('sale','capture','refund') then transaction_refund_adjustment.adjusted_amount end) as average_order_value,
        sum(case when lower(transaction_refund_adjustment.kind) in ('sale','capture','refund') then transaction_refund_adjustment.adjusted_amount end) as lifetime_total_amount,
        sum(case when lower(transaction_refund_adjustment.kind) in ('sale','capture') then 1 else 0 end) as lifetime_count_orders
    from orders
    left join transaction_refund_adjustment
        using (order_id)
    where customer_id is not null
    group by 1

)

select *
from aggregated