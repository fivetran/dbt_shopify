with products as (

    select *
    from {{ ref('int_shopify__products_with_aggregates') }}

), order_lines as (

    select *
    from {{ ref('int_shopify__product__order_line_aggregates')}}

), joined as (

    select
        products.*,
        coalesce(order_lines.quantity_sold,0) as total_quantity_sold,
        coalesce(order_lines.subtotal_sold,0) as subtotal_sold,
        coalesce(order_lines.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        coalesce(order_lines.subtotal_sold_net_refunds,0) as subtotal_sold_net_refunds,
        order_lines.first_order_timestamp,
        order_lines.most_recent_order_timestamp,
        -- start new columns
        coalesce(order_lines.average_quantity_per_order,0) as average_quantity_per_order,
        coalesce(order_lines.product_total_discount,0) as product_total_discount,
        coalesce(order_lines.product_average_discount_per_order,0) as product_average_discount_per_order,
        coalesce(order_lines.product_total_tax,0) as product_total_tax,
        coalesce(order_lines.product_average_tax_per_order,0) as product_average_tax_per_order

    from products
    left join order_lines
        on products.product_id = order_lines.product_id
        and products.source_relation = order_lines.source_relation
)

select *
from joined