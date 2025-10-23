{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{% set metafields_enabled = var('shopify_gql_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_customer_metafields', True)) %}

with customers as (

    select 
        {{ dbt_utils.star(from=(ref('shopify_gql__customer_metafields') if metafields_enabled else ref('int_shopify_gql__customer')), except=["orders_count", "total_spent", "unique_key"]) }}
    from {{ ref('shopify_gql__customer_metafields') if metafields_enabled else ref('int_shopify_gql__customer') }}

), orders as (

    select *
    from {{ ref('int_shopify_gql__customers_order_aggregates' )}}

{% if var('shopify_gql_using_abandoned_checkout', True) %}
), abandoned as (

    select 
        customer_id,
        source_relation,
        count(distinct checkout_id) as lifetime_abandoned_checkouts
    from {{ ref('stg_shopify_gql__abandoned_checkout') }}
    where customer_id is not null
    group by 1,2
{% endif %}

), customer_tags_aggregated as (

    select 
        customer_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(value as " ~ dbt.type_string() ~ ")", "', '") }} as customer_tags

    from {{ ref('stg_shopify_gql__customer_tag') }}
    group by 1,2

), joined as (

    select 
        customers.*,

        {% if var('shopify_gql_using_abandoned_checkout', True) %}
        coalesce(abandoned.lifetime_abandoned_checkouts, 0) as lifetime_abandoned_checkouts,
        {% endif %}

        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        customer_tags_aggregated.customer_tags,
        orders.avg_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_net,
        coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders,
        orders.avg_quantity_per_order,
        coalesce(orders.lifetime_total_tax, 0) as lifetime_total_tax,
        orders.avg_tax_per_order,
        coalesce(orders.lifetime_total_discount, 0) as lifetime_total_discount,
        orders.avg_discount_per_order,
        coalesce(orders.lifetime_total_shipping, 0) as lifetime_total_shipping,
        orders.avg_shipping_per_order,
        coalesce(orders.lifetime_total_shipping_with_discounts, 0) as lifetime_total_shipping_with_discounts,
        orders.avg_shipping_with_discounts_per_order,
        coalesce(orders.lifetime_total_shipping_tax, 0) as lifetime_total_shipping_tax,
        orders.avg_shipping_tax_per_order

    from customers
    left join orders
        on customers.customer_id = orders.customer_id
        and customers.source_relation = orders.source_relation
    left join customer_tags_aggregated
        on customers.customer_id = customer_tags_aggregated.customer_id
        and customers.source_relation = customer_tags_aggregated.source_relation
    
    {% if var('shopify_gql_using_abandoned_checkout', True) %}
    left join abandoned
        on customers.customer_id = abandoned.customer_id
        and customers.source_relation = abandoned.source_relation
    {% endif %}

)

select *
from joined