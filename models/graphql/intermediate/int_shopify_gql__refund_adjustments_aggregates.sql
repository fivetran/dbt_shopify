{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

/*
    This model aggregates refund adjustments, specifically filtering for 'refund_discrepancy' type.

    KEY INSIGHT: Refund discrepancies are included in ORDER_LINE_REFUND.subtotal but Shopify
    Analytics EXCLUDES them from the Returns metric. 

    This implements the customer's adjustments_daily CTE logic.

    NOTE: The GraphQL connector uses 'reason' field. The REST connector uses 'kind' field.
    We check for 'refund_discrepancy' in the reason field for GraphQL.
*/

with order_adjustment as (

    select *
    from {{ ref('int_shopify_gql__order_adjustment') }}

), refund as (

    select *
    from {{ ref('stg_shopify_gql__refund') }}

), refund_discrepancy_by_refund as (

    select
        refund.refund_id,
        refund.order_id,
        refund.source_relation,

        -- Sum adjustments by type (Customer Fix #4)
        sum(case when order_adjustment.reason = 'refund_discrepancy'
                 then order_adjustment.amount_shop
                 else 0
            end) as refund_discrepancy_amount,

        sum(case when order_adjustment.reason = 'refund_discrepancy'
                 then order_adjustment.tax_amount_shop
                 else 0
            end) as refund_discrepancy_tax,

        -- Track other adjustment types for transparency
        sum(case when order_adjustment.reason != 'refund_discrepancy'
                      or order_adjustment.reason is null
                 then order_adjustment.amount_shop
                 else 0
            end) as other_adjustment_amount

    from refund
    left join order_adjustment
        on refund.refund_id = order_adjustment.refund_id
        and refund.source_relation = order_adjustment.source_relation

    group by 1, 2, 3

), refund_discrepancy_by_order as (

    select
        order_id,
        source_relation,
        sum(refund_discrepancy_amount) as order_refund_discrepancy_amount,
        sum(refund_discrepancy_tax) as order_refund_discrepancy_tax,
        sum(other_adjustment_amount) as order_other_adjustment_amount

    from refund_discrepancy_by_refund
    group by 1, 2

)

select *
from refund_discrepancy_by_order
