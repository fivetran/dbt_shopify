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
        source_relation,
        is_gift_card
    from {{ ref('stg_shopify__order_line') }}

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
        order_line_refunds.subtotal,
        order_line_refunds.total_tax,
        order_lines.is_gift_card

    from refunds
    left join order_line_refunds
        on refunds.refund_id = order_line_refunds.refund_id
        and refunds.source_relation = order_line_refunds.source_relation
    left join order_lines
        on order_line_refunds.order_line_id = order_lines.order_line_id
        and order_line_refunds.source_relation = order_lines.source_relation

)

select *
from refund_join
