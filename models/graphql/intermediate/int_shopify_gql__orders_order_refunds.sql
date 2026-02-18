{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

/*
    CRITICAL UPDATE: Gift cards are now EXCLUDED from refund calculations.

    This model joins to ORDER_LINE to check is_gift_card flag and filters out
    gift card refunds to match Shopify Analytics behavior (Customer Fix #3).

    Gift card refunds are tracked separately for transparency.
*/

with refunds as (

    select *
    from {{ ref('stg_shopify_gql__refund') }}

), order_line_refunds as (

    select *
    from {{ ref('stg_shopify_gql__order_line_refund') }}

), order_line as (

    select *
    from {{ ref('stg_shopify_gql__order_line') }}

), refund_join as (

    select
        refunds.refund_id,
        refunds.created_at,
        refunds.order_id,
        refunds.user_id,
        refunds.source_relation,
        order_line_refunds.order_line_refund_id,
        order_line_refunds.order_line_id,
        order_line_refunds.restock_type,
        order_line_refunds.quantity,

        -- UPDATED: Only include non-gift-card refunds in main subtotal (Customer Fix #3)
        case when order_line.is_gift_card = false
             then order_line_refunds.subtotal_shop_amount
             else 0
        end as subtotal,

        case when order_line.is_gift_card = false
             then order_line_refunds.total_tax_shop_amount
             else 0
        end as total_tax,

        -- NEW: Track gift card refunds separately for transparency
        case when order_line.is_gift_card = true
             then order_line_refunds.subtotal_shop_amount
             else 0
        end as gift_card_refund_subtotal,

        case when order_line.is_gift_card = true
             then order_line_refunds.total_tax_shop_amount
             else 0
        end as gift_card_refund_tax,

        order_line.is_gift_card

    from refunds
    left join order_line_refunds
        on refunds.refund_id = order_line_refunds.refund_id
        and refunds.source_relation = order_line_refunds.source_relation

    -- NEW: Join to order_line to get gift_card flag (Customer Fix #3)
    left join order_line
        on order_line_refunds.order_line_id = order_line.order_line_id
        and order_line_refunds.source_relation = order_line.source_relation

)

select *
from refund_join
