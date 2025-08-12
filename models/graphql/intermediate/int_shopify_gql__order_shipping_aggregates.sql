{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_shipping_line as (

    select
        order_id,
        source_relation,
        order_shipping_line_id,
        sum(coalesce(price_shop_amount, 0)) as shipping_price,
        sum(coalesce(discounted_price_shop_amount, 0)) as discounted_shipping_price
        
    from {{ ref('stg_shopify_gql__order_shipping_line') }}
    group by 1,2,3

), order_shipping_tax_line as (

    select
        order_shipping_line_id,
        source_relation,
        sum(coalesce(price_shop_amount, 0)) as shipping_tax

    from {{ ref('stg_shopify_gql__order_shipping_tax_line') }}
    group by 1,2 

), aggregated as (

    select 
        order_shipping_line.order_id,
        order_shipping_line.source_relation,
        sum(coalesce(order_shipping_line.shipping_price, 0)) as shipping_price,
        sum(coalesce(order_shipping_line.discounted_shipping_price, 0)) as discounted_shipping_price,
        sum(coalesce(order_shipping_tax_line.shipping_tax, 0)) as shipping_tax

    from order_shipping_line
    left join order_shipping_tax_line
        on order_shipping_line.order_shipping_line_id = order_shipping_tax_line.order_shipping_line_id
        and order_shipping_line.source_relation = order_shipping_tax_line.source_relation
    group by 1,2
)

select * 
from aggregated