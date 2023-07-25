with shipping_order_lines as (

    select *
    from {{ var('shopify_order_shipping_line') }}

),tax_lines as (

    select *
    from {{ var('shopify_order_shipping_tax_line')}}

), tax_lines_aggregated as (

    select
        tax_lines.order_shipping_line_id,
        tax_lines.source_relation,
        sum(tax_lines.price) as order_line_tax

    from tax_lines
    group by 1,2

), discount_allocation as (

    select *
    from {{ var('shopify_discount_allocation') }}

),
joined as (

    select
        shipping_order_lines.*,
        tax_lines_aggregated.order_line_tax,
        discount_allocation.amount AS order_line_discount_allocation

    from shipping_order_lines
    left join tax_lines_aggregated
        on tax_lines_aggregated.order_shipping_line_id = shipping_order_lines.order_shipping_line_id
        and tax_lines_aggregated.source_relation = shipping_order_lines.source_relation
    left join discount_allocation
        ON discount_allocation.order_line_id = shipping_order_lines.order_shipping_line_id
        AND discount_allocation.source_relation = shipping_order_lines.source_relation
)

select *
from joined
