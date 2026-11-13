{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with allocations as (
    select order_line_id, source_relation, sum(amount) as discount_amount
    from {{ ref('stg_shopify__discount_allocation') }}
    group by 1,2
)

select lines.order_line_id, lines.source_relation, lines.subtotal_net_refunds
from {{ ref('shopify__order_lines') }} as lines
left join allocations
    on lines.order_line_id = allocations.order_line_id
    and lines.source_relation = allocations.source_relation
where lines.subtotal_net_refunds is null
    or abs(lines.subtotal_net_refunds - (
        lines.price * lines.quantity - coalesce(allocations.discount_amount, 0) - lines.refunded_subtotal
    )) > 0.01
