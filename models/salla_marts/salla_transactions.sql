with transactions as (

    select *
    from {{ ref('stg_salla__transaction') }}

), orders as (

    select
        order_id,
        source_relation,
        customer_id,
        order_date,
        reference_id,
        cast(json_extract_scalar(status, '$.name') as string) as order_status_name
    from {{ ref('stg_salla__order') }}

), joined as (

    select
        transactions.transaction_id,
        transactions.order_id,
        transactions.source_relation,

        -- order info
        orders.customer_id,
        orders.order_date,
        orders.reference_id,
        orders.order_status_name,

        -- transaction info
        transactions.gateway_transaction_id,
        transactions.transaction_type,
        transactions.transaction_status,
        transactions.payment_method,
        transactions.amount,
        transactions.currency,

        -- gateway response
        transactions.gateway_response,

        -- dates
        transactions.created_timestamp,
        transactions.updated_timestamp,
        transactions.processed_timestamp

    from transactions
    left join orders
        on transactions.order_id = orders.order_id
        and transactions.source_relation = orders.source_relation

)

select *
from joined
