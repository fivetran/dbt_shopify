with order_lines as (

    select *
    from {{ var('shopify_order_line') }}

), order_line_refunds as (

    select *
    from {{ var('shopify_order_line_refund') }}

), refunds_aggregated as (

    select
        order_line_id,
        sum(quantity) as refunded_quantity
    from order_line_refunds
    group by 1

), joined as (

    select
        order_lines.*,
        coalesce(refunds_aggregated.refunded_quantity,0) as refunded_quantity,
        order_lines.quantity - coalesce(refunds_aggregated.refunded_quantity,0) as quantity_net_refunds
    from order_lines
    left join refunds_aggregated
        using (order_line_id)

)

select *
from joined