{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

/*
    Canonical refund events model with return context.
    - Uses refund.created_at instead of order date for accurate date attribution 
 
*/

with refunds as (

    select *
    from {{ ref('stg_shopify__refund') }}

), refund_lines as (

    select *
    from {{ ref('shopify__orders__order_refunds') }} 

), refund_adjustments as (

    select *
    from {{ ref('int_shopify__refund_adjustments_aggregates') }} 

), return_line_items as (

    select *
    from {{ ref('stg_shopify__return_line_item') }} 

), refund_events as (

    select
        refunds.refund_id,
        refunds.order_id,
        refunds.source_relation,
        refunds.created_at as refund_created_at,
        cast({{ dbt.date_trunc('day', 'refunds.created_at') }} as date) as refund_date,

        -- Line-level details
        refund_lines.order_line_id,
        refund_lines.order_line_refund_id,
        refund_lines.quantity as refunded_quantity,
        refund_lines.is_gift_card,
        refund_lines.restock_type,

        -- Financial amounts (Phase 1 gift card filtering applied)
        refund_lines.subtotal as refund_subtotal,
        refund_lines.total_tax as refund_tax,
        refund_lines.subtotal + refund_lines.total_tax as refund_total,

        -- Gift card refunds tracked separately
        refund_lines.gift_card_refund_subtotal,
        refund_lines.gift_card_refund_tax,

        -- Refund discrepancies (Phase 1)
        refund_adjustments.order_refund_discrepancy_amount,
        refund_adjustments.order_refund_discrepancy_tax,

        -- Metadata
        refunds.note as refund_note,
        refunds.user_id as refund_staff_member_id,

        -- Phase 3: Return context (when available)
        return_line_items.return_reason,
        return_line_items.return_reason_note,
        return_line_items.refundable_quantity,
        return_line_items.refunded_quantity as return_refunded_quantity,

        -- Inventory impact flags
        case when refund_lines.restock_type in ('return', 'cancel')
             then true else false
        end as was_restocked

    from refunds
    left join refund_lines
        on refunds.refund_id = refund_lines.refund_id
        and refunds.source_relation = refund_lines.source_relation
    left join refund_adjustments
        on refunds.order_id = refund_adjustments.order_id
        and refunds.source_relation = refund_adjustments.source_relation

    -- Phase 3: Left join return data (nullable - not all refunds have returns)
    left join return_line_items
        on refund_lines.order_line_id = return_line_items.fulfillment_line_item_id
        and refunds.source_relation = return_line_items.source_relation

)

select *
from refund_events
