with order_lines as (

    select * from {{ ref('airshopify__order_lines') }}

), aggregated as (

    select
        product_id,
        source_relation,
        sum(quantity) as quantity_sold,
        sum(price * quantity) as subtotal_sold,
        sum(quantity_net_refunds) as quantity_sold_net_refunds,
        sum(subtotal_net_refunds) as subtotal_sold_net_refunds,
        min({{ ref('stg_shopify__order') }}.created_timestamp) as first_order_timestamp,
        max({{ ref('stg_shopify__order') }}.created_timestamp) as most_recent_order_timestamp,
        avg(quantity) as avg_quantity_per_order_line,
        sum(total_discount) as product_total_discount,
        avg(total_discount) as product_avg_discount_per_order_line,
        sum(order_line_tax) as product_total_tax,
        avg(order_line_tax) as product_avg_tax_per_order_line

    from order_lines
    left join {{ ref('stg_shopify__order') }}
        on order_lines.order_id = {{ ref('stg_shopify__order') }}.order_id
        and order_lines.source_relation = {{ ref('stg_shopify__order') }}.source_relation
    where product_id is not null
    group by 1, 2

)

select * from aggregated
