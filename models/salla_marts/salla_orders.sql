with orders as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'order_id']) }} as orders_unique_key
    from {{ ref('stg_salla__order') }}

), order_lines as (

    select *
    from {{ ref('int_salla__order__line_aggregates') }}

), transactions as (

    select
        order_id,
        source_relation,
        sum(case when lower(transaction_status) = 'success' then amount else 0 end) as total_paid,
        max(processed_timestamp) as last_payment_timestamp
    from {{ ref('stg_salla__transaction') }}
    group by 1, 2

), shipments as (

    select
        order_id,
        source_relation,
        count(shipment_id) as number_of_shipments,
        string_agg(distinct cast(tracking_number as string), ', ') as tracking_numbers,
        sum(shipment_cost) as total_shipping_cost
    from {{ ref('stg_salla__order_shipment') }}
    group by 1, 2

), joined as (

    select
        orders.*,

        -- Parse total amounts from JSON
        cast(json_extract_scalar(orders.total, '$.amount') as numeric) as total_amount,
        json_extract_scalar(orders.total, '$.currency') as currency,

        -- Parse status from JSON
        cast(json_extract_scalar(orders.status, '$.id') as int64) as status_id,
        json_extract_scalar(orders.status, '$.name') as status_name,

        order_lines.line_item_count,
        order_lines.order_total_quantity,
        order_lines.order_total_line_items_price,

        coalesce(transactions.total_paid, 0) as total_paid,
        transactions.last_payment_timestamp,

        coalesce(shipments.number_of_shipments, 0) as number_of_shipments,
        shipments.tracking_numbers,
        coalesce(shipments.total_shipping_cost, 0) as total_shipping_cost

    from orders
    left join order_lines
        on orders.order_id = order_lines.order_id
        and orders.source_relation = order_lines.source_relation
    left join transactions
        on orders.order_id = transactions.order_id
        and orders.source_relation = transactions.source_relation
    left join shipments
        on orders.order_id = shipments.order_id
        and orders.source_relation = shipments.source_relation

), windows as (

    select
        *,
        row_number() over (
            partition by customer_id, source_relation
            order by created_timestamp)
            as customer_order_seq_number
    from joined

), new_vs_repeat as (

    select
        *,
        case
            when customer_order_seq_number = 1 then 'new'
            else 'repeat'
        end as new_vs_repeat
    from windows

)

select *
from new_vs_repeat
