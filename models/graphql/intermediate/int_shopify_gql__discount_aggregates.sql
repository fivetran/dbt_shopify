{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with discount_allocation as (

    select *
    from {{ ref('stg_shopify_gql__discount_allocation') }}

), order_line as (

    select *
    from {{ ref('stg_shopify_gql__order_line') }}

), discount_by_order_line as (

    select
        order_line.order_id,
        order_line.order_line_id,
        order_line.source_relation,
        sum(coalesce(discount_allocation.allocated_shop_amount, 0)) as line_discount_shop_amount,
        sum(coalesce(discount_allocation.allocated_pres_amount, 0)) as line_discount_pres_amount

    from order_line
    left join discount_allocation
        on order_line.order_line_id = discount_allocation.order_line_id
        and order_line.source_relation = discount_allocation.source_relation

    group by 1, 2, 3

), discount_by_order as (

    select
        order_id,
        source_relation,
        sum(line_discount_shop_amount) as order_total_discount_shop_amount,
        sum(line_discount_pres_amount) as order_total_discount_pres_amount

    from discount_by_order_line
    group by 1, 2

)

select *
from discount_by_order
