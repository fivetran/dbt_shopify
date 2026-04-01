{{ config(materialized='table', enabled=var('shopify_api', 'rest') == 'rest') }}

with order_line as (

    select *
    from {{ ref('stg_shopify__order_line') }}

), tax as (

    select
        *
    from {{ ref('stg_shopify__tax_line') }}

), shipping as (

    select
        *
    from {{ ref('int_shopify__order__shipping_aggregates')}}

), orders as (

    select
        order_id,
        source_relation,
        financial_status
    from {{ ref('stg_shopify__order') }}

), discount_allocation as (

    select *
    from {{ ref('stg_shopify__discount_allocation') }}

), tax_aggregates as (

    select
        order_line_id,
        source_relation,
        sum(price) as price

    from tax
    group by 1,2

), discount_allocation_aggregates as (

    select
        order_line_id,
        source_relation,
        sum(amount) as discount_allocation_amount

    from discount_allocation
    group by 1,2

), order_line_aggregates as (

    select
        order_line.order_id,
        order_line.source_relation,
        count(*) as line_item_count,
        sum(order_line.quantity) as order_total_quantity,
        sum(tax_aggregates.price) as order_total_tax,
        sum(order_line.total_discount) as order_total_discount,
        sum(case when not order_line.is_gift_card and coalesce(orders.financial_status, '') != 'voided' then order_line.quantity * order_line.price else 0 end) as gross_sales,
        sum(coalesce(discount_allocation_aggregates.discount_allocation_amount, 0)) as discount_allocation_amount

    from order_line
    left join orders
        on orders.order_id = order_line.order_id
        and orders.source_relation = order_line.source_relation
    left join tax_aggregates
        on tax_aggregates.order_line_id = order_line.order_line_id
        and tax_aggregates.source_relation = order_line.source_relation
    left join discount_allocation_aggregates
        on discount_allocation_aggregates.order_line_id = order_line.order_line_id
        and discount_allocation_aggregates.source_relation = order_line.source_relation
    group by 1,2

), final as (

    select
        order_line_aggregates.order_id,
        order_line_aggregates.source_relation,
        order_line_aggregates.line_item_count,
        order_line_aggregates.order_total_quantity,
        order_line_aggregates.order_total_tax,
        order_line_aggregates.order_total_discount,
        order_line_aggregates.gross_sales,
        order_line_aggregates.discount_allocation_amount,
        shipping.shipping_price as order_total_shipping,
        shipping.discounted_shipping_price as order_total_shipping_with_discounts,
        shipping.shipping_tax as order_total_shipping_tax

    from order_line_aggregates
    left join shipping
        on shipping.order_id = order_line_aggregates.order_id
        and shipping.source_relation = order_line_aggregates.source_relation
)

select *
from final