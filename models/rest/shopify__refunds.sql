{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with refunds as (

    select *
    from {{ ref('stg_shopify__refund') }}

), order_line_refunds as (

    select *
    from {{ ref('stg_shopify__order_line_refund') }}

), order_lines as (

    select
        order_line_id,
        order_id,
        source_relation,
        product_id,
        variant_id,
        title,
        sku,
        price as original_unit_price,
        is_gift_card,
        vendor
    from {{ ref('stg_shopify__order_line') }}

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

    -- Refund discrepancy adjustments are refund-level corrections applied when the sum of
    -- line item refunds does not exactly match the total refund amount processed.
    -- Caution: this amount repeats across all order_line_refund rows for the same refund_id.
    -- Do not sum this field when aggregating at the order_line_refund grain.
    select
        refund_id,
        source_relation,
        sum(amount) as refund_discrepancy_amount,
        sum(tax_amount) as refund_discrepancy_tax_amount
    from {{ ref('stg_shopify__order_adjustment') }}
    where lower(kind) = 'refund_discrepancy'
    group by 1, 2

), joined as (

    select
        -- identity / keys
        {{ dbt_utils.generate_surrogate_key(['order_line_refunds.order_line_refund_id', 'order_line_refunds.source_relation']) }} as unique_key,
        refunds.refund_id,
        order_line_refunds.order_line_refund_id,
        order_line_refunds.order_line_id,
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

        -- product context (values at time of original order)
        order_lines.product_id,
        order_lines.variant_id,
        order_lines.title as product_title,
        order_lines.sku,
        order_lines.vendor,
        order_lines.original_unit_price,
        order_lines.is_gift_card,

        -- refund line financials
        order_line_refunds.quantity as refunded_quantity,
        coalesce(order_line_refunds.subtotal, 0) as subtotal,
        coalesce(order_line_refunds.total_tax, 0) as total_tax,
        coalesce(order_line_refunds.subtotal, 0) + coalesce(order_line_refunds.total_tax, 0) as total_refunded,

        -- inventory / restock classification
        order_line_refunds.restock_type,
        order_line_refunds.location_id as restock_location_id,
        order_line_refunds.restock_type in ('return', 'cancel', 'legacy_restock') as is_restocked,
        (coalesce(order_line_refunds.subtotal, 0) = 0
            and coalesce(order_line_refunds.total_tax, 0) = 0
            and order_line_refunds.restock_type
                in ('return', 'cancel', 'legacy_restock'))              as is_restock_only,

        -- refund-level discrepancy adjustment
        order_adjustment_aggregates.refund_discrepancy_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_amount,
        refunds.source_relation

    from order_line_refunds
    join refunds
        on order_line_refunds.refund_id = refunds.refund_id
        and order_line_refunds.source_relation = refunds.source_relation
    left join order_lines
        on order_line_refunds.order_line_id = order_lines.order_line_id
        and order_line_refunds.source_relation = order_lines.source_relation
    left join orders
        on refunds.order_id = orders.order_id
        and refunds.source_relation = orders.source_relation
    left join order_adjustment_aggregates
        on refunds.refund_id = order_adjustment_aggregates.refund_id
        and refunds.source_relation = order_adjustment_aggregates.source_relation

)

select *
from joined
