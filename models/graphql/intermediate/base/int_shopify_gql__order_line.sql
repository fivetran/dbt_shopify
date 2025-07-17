{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_line as (
    
    select *
    from {{ var('shopify_gql_order_line') }}
),

tax_line as (

    select *
    from {{ var('shopify_gql_tax_line') }}
),

tax_line_aggregated as (

    select
        tax_line.order_line_id,
        tax_line.source_relation,
        sum(tax_line.price_shop_amount) as order_line_tax
    from tax_line
    group by 1,2
),

joined as (

    select
        order_line.*,
        coalesce(order_line.price_shop_amount, 0) - coalesce(tax_line_aggregated.order_line_tax, 0) as pre_tax_price,
        tax_line_aggregated.order_line_tax

    from order_line
    left join tax_line_aggregated
        on tax_line_aggregated.order_line_id = order_line.order_line_id
        and tax_line_aggregated.source_relation = order_line.source_relation
)

select *
from joined