{{ config(
    materialized='table', 
    enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')
) }}

with order_line as (

    select *
    from {{ var('shopify_gql_order_line') }}

), tax as (

    select
        *
    from {{ var('shopify_gql_tax_line') }}

), shipping as (

    select
        *
    from {{ ref('int_shopify_gql__order_shipping_aggregates')}}

), tax_aggregates as (

    select
        order_line_id,
        source_relation,
        sum(coalesce(price_shop_amount, 0)) as price

    from tax
    group by 1,2

), order_line_aggregates as (

    select 
        order_line.order_id,
        order_line.source_relation,
        count(*) as line_item_count,
        sum(coalesce(order_line.quantity, 0)) as order_total_quantity,
        sum(coalesce(tax_aggregates.price, 0)) as order_total_tax,
        sum(coalesce(order_line.total_discount_shop_amount, 0)) as order_total_discount,
        sum(coalesce(price_pres_amount, 0)) as total_line_items_price_pres_amount,
        sum(coalesce(price_shop_amount, 0)) as total_line_items_price_shop_amount,
        {{ fivetran_utils.string_agg("distinct cast(order_line.price_pres_currency_code as " ~ dbt.type_string() ~ ")", "', '") }} as total_line_items_price_pres_currency_codes,
        {{ fivetran_utils.string_agg("distinct cast(order_line.price_shop_currency_code as " ~ dbt.type_string() ~ ")", "', '") }} as total_line_items_price_shop_currency_codes

    from order_line
    left join tax_aggregates
        on tax_aggregates.order_line_id = order_line.order_line_id
        and tax_aggregates.source_relation = order_line.source_relation
    group by 1,2

), final as (

    select
        order_line_aggregates.order_id,
        order_line_aggregates.source_relation,
        order_line_aggregates.line_item_count,
        order_line_aggregates.order_total_quantity,
        order_line_aggregates.order_total_tax,
        order_line_aggregates.order_total_discount,
        order_line_aggregates.total_line_items_price_pres_amount,
        order_line_aggregates.total_line_items_price_shop_amount,
        order_line_aggregates.total_line_items_price_pres_currency_codes,
        order_line_aggregates.total_line_items_price_shop_currency_codes,
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