{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with refunds as (

    select *
    from {{ ref('stg_shopify__refund') }}

), orders as (

    select
        order_id,
        source_relation,
        customer_id,
        email,
        source_name,
        created_timestamp as order_created_at
    from {{ ref('stg_shopify__order') }}

), order_adjustment_aggregates as (

    select
        refund_id,
        source_relation,
        sum(amount) as refund_discrepancy_amount,
        sum(tax_amount) as refund_discrepancy_tax_amount
    from {{ ref('stg_shopify__order_adjustment') }}
    where lower(kind) = 'refund_discrepancy'
    group by 1, 2

), refund_line_aggregates as (

    select
        refund_id,
        source_relation,
        count(*) as count_refund_line_items,
        sum(quantity) as total_quantity_refunded,
        sum(coalesce(subtotal, 0)) as subtotal,
        sum(coalesce(total_tax, 0)) as total_tax,
        sum(coalesce(subtotal, 0)) + sum(coalesce(total_tax, 0)) as total_refunded,
        sum(case when restock_type in ('return', 'cancel', 'legacy_restock') then quantity else 0 end) as quantity_restocked,
        count(case when restock_type in ('return', 'cancel', 'legacy_restock') then 1 end) as count_restocked_line_items
    from {{ ref('stg_shopify__order_line_refund') }}
    group by 1, 2

), joined as (

    select
        -- identity / keys
        {{ dbt_utils.generate_surrogate_key(['refunds.refund_id', 'refunds.source_relation']) }} as unique_key,
        refunds.refund_id,
        refunds.source_relation,
        refunds.order_id,

        -- order context
        orders.customer_id,
        orders.email,
        orders.source_name as order_channel,
        orders.order_created_at,

        -- timing
        refunds.created_at as refund_created_at,
        refunds.processed_at as refund_processed_at,
        refunds.processed_at is not null as is_processed,
        {{ dbt.datediff('cast(orders.order_created_at as date)', 'cast(refunds.created_at as date)', 'day') }} as days_to_refund,

        -- refund metadata
        refunds.note as refund_note,
        refunds.user_id as staff_user_id,

        -- line item aggregates
        coalesce(refund_line_aggregates.count_refund_line_items, 0) as count_refund_line_items,
        coalesce(refund_line_aggregates.total_quantity_refunded, 0) as total_quantity_refunded,
        coalesce(refund_line_aggregates.subtotal, 0) as subtotal,
        coalesce(refund_line_aggregates.total_tax, 0) as total_tax,
        coalesce(refund_line_aggregates.total_refunded, 0) as total_refunded,

        -- restock summary
        coalesce(refund_line_aggregates.quantity_restocked, 0) as quantity_restocked,
        coalesce(refund_line_aggregates.count_restocked_line_items, 0) as count_restocked_line_items,
        coalesce(refund_line_aggregates.count_restocked_line_items, 0) > 0 as has_restock,

        -- discrepancy adjustment (difference between sum of line items and actual amount processed)
        order_adjustment_aggregates.refund_discrepancy_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_amount

    from refunds
    left join orders
        on refunds.order_id = orders.order_id
        and refunds.source_relation = orders.source_relation
    left join refund_line_aggregates
        on refunds.refund_id = refund_line_aggregates.refund_id
        and refunds.source_relation = refund_line_aggregates.source_relation
    left join order_adjustment_aggregates
        on refunds.refund_id = order_adjustment_aggregates.refund_id
        and refunds.source_relation = order_adjustment_aggregates.source_relation
)

select *
from joined
