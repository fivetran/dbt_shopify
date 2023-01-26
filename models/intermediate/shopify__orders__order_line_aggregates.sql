with order_line as (

    select *
    from {{ var('shopify_order_line') }}

), tax as (

    select
        *
    from {{ var('shopify_tax_line') }}

), shipping as (

    select
        *
    from {{ ref('int_shopify__order_shipping_aggregates')}}

), aggregated as (

    select 
        order_line.order_id,
        order_line.source_relation,
        count(*) as line_item_count,
        -- start new columns QUESTION: do I need to consider currency for the below?
        sum(order_line.quantity) as order_total_quantity,
        sum(tax.price) as order_total_tax,
        sum(order_line.total_discount) as order_total_discount,
        sum(shipping.shipping_price) as order_total_shipping,
        sum(shipping.discounted_shipping_price) as order_total_shipping_with_discounts,
        sum(shipping.shipping_tax) as order_total_shipping_tax

    from order_line
    left join tax
        on tax.order_line_id = order_line.order_line_id
        and tax.source_relation = order_line.source_relation
    left join shipping
        on shipping.order_id = order_line.order_id
        and shipping.source_relation = order_line.source_relation
    group by 1,2

)

select *
from aggregated