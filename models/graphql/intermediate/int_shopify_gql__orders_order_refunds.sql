{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with refunds as (

    select *
    from {{ ref('stg_shopify_gql__refund') }}

), order_line_refunds as (

    select *
    from {{ ref('stg_shopify_gql__order_line_refund') }}
    
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
        order_line_refunds.subtotal_shop_amount as subtotal,
        order_line_refunds.total_tax_shop_amount as total_tax

    from refunds
    left join order_line_refunds
        on refunds.refund_id = order_line_refunds.refund_id
        and refunds.source_relation = order_line_refunds.source_relation

)

select *
from refund_join
