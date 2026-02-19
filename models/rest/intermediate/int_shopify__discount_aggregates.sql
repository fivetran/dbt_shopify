{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with discount_allocation as (

    select *
    from {{ ref('stg_shopify__discount_allocation') }}

), order_line as (

    select *
    from {{ ref('stg_shopify__order_line') }}

), discount_by_order_line as (

    select
        order_line.order_id,
        order_line.order_line_id,
        order_line.source_relation,
        -- Sum all discount allocations for this order line 
        sum(coalesce(discount_allocation.amount, 0)) as line_discount_amount

    from order_line
    left join discount_allocation
        on order_line.order_line_id = discount_allocation.order_line_id
        and order_line.source_relation = discount_allocation.source_relation

    group by 1, 2, 3

), discount_by_order as (

    select
        order_id,
        source_relation,
        -- Aggregate to order level
        sum(line_discount_amount) as order_total_discount

    from discount_by_order_line
    group by 1, 2

)

select *
from discount_by_order
