with order_lines as (

    select * from {{ ref('airshopify__order_lines') }}

), orders as (

    select * from {{ ref('airshopify__orders') }}

), aggregated as (

    select
        order_lines.variant_id,
        order_lines.product_id,
        order_lines.source_relation,

        -- sales metrics
        sum(order_lines.price * order_lines.quantity) as subtotal_sold,
        sum(order_lines.quantity) as quantity_sold,
        count(distinct orders.order_id) as count_distinct_orders,
        count(distinct orders.customer_id) as count_distinct_customers,
        count(distinct orders.email) as count_distinct_customer_emails,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as last_order_timestamp,

        -- refunds
        sum(order_lines.refunded_subtotal) as subtotal_sold_refunds,
        sum(order_lines.refunded_quantity) as quantity_sold_refunds,

        -- fulfillment status counts
        sum(case when order_lines.fulfillment_status = 'pending' then 1 else 0 end) as count_fulfillment_pending,
        sum(case when order_lines.fulfillment_status = 'open' then 1 else 0 end) as count_fulfillment_open,
        sum(case when order_lines.fulfillment_status = 'success' then 1 else 0 end) as count_fulfillment_success,
        sum(case when order_lines.fulfillment_status = 'cancelled' then 1 else 0 end) as count_fulfillment_cancelled,
        sum(case when order_lines.fulfillment_status = 'error' then 1 else 0 end) as count_fulfillment_error,
        sum(case when order_lines.fulfillment_status = 'failure' then 1 else 0 end) as count_fulfillment_failure,

        -- net metrics
        sum(order_lines.subtotal_net_refunds) as net_subtotal_sold,
        sum(order_lines.quantity_net_refunds) as net_quantity_sold

    from order_lines
    left join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation
    where order_lines.variant_id is not null
    group by 1, 2, 3

)

select * from aggregated
