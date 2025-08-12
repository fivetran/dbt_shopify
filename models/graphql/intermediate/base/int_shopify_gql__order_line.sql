{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_line as (
    
    select *
    from {{ ref('stg_shopify_gql__order_line') }}
),

tax_line as (

    select *
    from {{ ref('stg_shopify_gql__tax_line') }}
),

tax_line_aggregated as (

    select
        tax_line.order_line_id,
        tax_line.source_relation,
        sum(tax_line.price_shop_amount) as order_line_tax
    from tax_line
    group by 1,2
),

{% if var('shopify_gql_using_fulfillment_order_line_item', True) %}
fulfillment_order_line_item as (

    select *
    from {{ ref('stg_shopify_gql__fulfillment_order_line_item') }}
),
{% endif %}

joined as (

    select
        order_line.*,
        coalesce(order_line.price_shop_amount, 0) - coalesce(tax_line_aggregated.order_line_tax, 0) as pre_tax_price,
        tax_line_aggregated.order_line_tax,
        {% if var('shopify_gql_using_fulfillment_order_line_item', True) %}
        fulfillment_order_line_item.remaining_quantity as fulfillable_quantity,
        fulfillment_order_line_item.weight_unit,
        fulfillment_order_line_item.weight_value
        {% else %}
        cast(null as {{ dbt.type_int() }}) as fulfillable_quantity,
        cast(null as {{ dbt.type_string() }}) as weight_unit,
        cast(null as {{ dbt.type_float() }}) as weight_value
        {% endif %}

    from order_line
    left join tax_line_aggregated
        on tax_line_aggregated.order_line_id = order_line.order_line_id
        and tax_line_aggregated.source_relation = order_line.source_relation
    
    {% if var('shopify_gql_using_fulfillment_order_line_item', True) %}
    left join fulfillment_order_line_item
        on fulfillment_order_line_item.order_line_item_id = order_line.order_line_id
        and fulfillment_order_line_item.source_relation = order_line.source_relation
    {% endif %}
)

select *
from joined