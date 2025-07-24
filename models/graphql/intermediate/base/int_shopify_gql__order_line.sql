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

fulfillment_order_line_item as (

    select *
    from {{ var('shopify_gql_fulfillment_order_line_item') }}
),

joined as (

    select
        order_line.*,
        coalesce(order_line.price_shop_amount, 0) - coalesce(tax_line_aggregated.order_line_tax, 0) as pre_tax_price,
        tax_line_aggregated.order_line_tax,
        fulfillment_order_line_item.remaining_quantity as fulfillable_quantity,
        {# QUESTION: in REST order_line had a grams field. Should we include the following regardless of the weight unit, or pull out grams specifically?  #}
        fulfillment_order_line_item.weight_unit,
        fulfillment_order_line_item.weight_value

    from order_line
    left join tax_line_aggregated
        on tax_line_aggregated.order_line_id = order_line.order_line_id
        and tax_line_aggregated.source_relation = order_line.source_relation
    left join fulfillment_order_line_item
        on fulfillment_order_line_item.order_line_item_id = order_line.order_line_id
        and fulfillment_order_line_item.source_relation = order_line.source_relation
)

select *
from joined