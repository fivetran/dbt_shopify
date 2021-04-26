with order_lines as (

    select *
    from {{ ref('stg_shopify__order_line') }}

), order_line_refunds as (

    select *
    from {{ ref('stg_shopify__order_line_refund') }}

), order_line_refund_amounts as (

    select *
    FROM {{ ref('shopify__transaction__refund_line_aggregates') }}

), refunds_aggregated as (

    select
        order_line_id,
        refund_id,
        sum(quantity) as refunded_quantity,
        sum(refund_amount) AS refunded_amount
    from order_line_refunds
    left join order_line_refund_amounts
        using (refund_id)
    group by 1,2

), joined as (

    select
        order_lines.*,
        refunds_aggregated.refund_id,
        coalesce(refunds_aggregated.refunded_quantity,0) as refunded_quantity,
        coalesce(refunds_aggregated.refunded_amount, 0) AS refunded_amount,
        order_lines.quantity - coalesce(refunds_aggregated.refunded_quantity,0) as quantity_net_refunds
    from order_lines
    left join refunds_aggregated
        using (order_line_id)

)

select * from joined
